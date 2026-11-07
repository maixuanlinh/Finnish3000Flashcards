import XCTest
import AVFoundation
import UIKit
@testable import SisuCards

final class LessonMediaTests: XCTestCase {
    func testRecordingKeyMatchesPublishedManifestConvention() {
        XCTAssertEqual(lessonMediaHash(Data("apple".utf8)),
                       "3a7bd3e2360a3d29eea436fcfb7e44c735d117c42d1c1835420b6b9942dd4f1b")
        XCTAssertEqual(lessonRecordingKey(language: "en-US", text: "apple"),
                       "audio/en-US/3a7bd3e2360a3d29eea436fcfb7e44c735d117c42d1c1835420b6b9942dd4f1b")
    }

    func testCatalogAcceptsVerifiedPackAndBoundedAsset() throws {
        let hash = String(repeating: "a", count: 64)
        let manifest = LessonMediaManifest(format: "sisu-lesson-media-v1",
            packs: [LessonMediaPack(file: "pack-\(hash).bin", bytes: 10, sha256: hash, starter: true)],
            assets: [LessonMediaItem(key: "image/example.jpg", offset: 2, bytes: 4,
                                           sha256: String(repeating: "b", count: 64), pack: "pack-\(hash).bin")],
            version: String(repeating: "c", count: 64))
        let catalog = try manifest.validated()
        XCTAssertEqual(catalog.packs.count, 1)
        XCTAssertEqual(catalog.itemByKey["image/example.jpg"]?.offset, 2)
    }

    func testCatalogRejectsTraversalAndOutOfBoundsAsset() {
        let hash = String(repeating: "a", count: 64)
        let pack = LessonMediaPack(file: "pack-\(hash).bin", bytes: 10, sha256: hash, starter: false)
        let invalid = LessonMediaManifest(format: "sisu-lesson-media-v1", packs: [pack],
            assets: [LessonMediaItem(key: "../progress.store", offset: 8, bytes: 4,
                                           sha256: String(repeating: "b", count: 64), pack: pack.file)],
            version: String(repeating: "c", count: 64))
        XCTAssertThrowsError(try invalid.validated())
    }

    func testStatusCountsBundledAndDownloadedProgress() {
        let status = LessonMediaStatus(totalBytes: 100, bundledBytes: 20, downloadedBytes: 30,
                                       cachedBytes: 4, partialBytes: 10, readyPacks: 2,
                                       packCount: 4, loading: false)
        XCTAssertEqual(status.remainingBytes, 40)
        XCTAssertEqual(status.storageUsedBytes, 44)
        XCTAssertEqual(status.progress, 0.6, accuracy: 0.0001)
        XCTAssertFalse(status.isReady)
    }

    func testCatalogRejectsDuplicateKeysAndOverflowingOffsets() {
        let hash = String(repeating: "a", count: 64)
        let pack = LessonMediaPack(file: "pack-\(hash).bin", bytes: 10, sha256: hash, starter: false)
        let item = LessonMediaItem(key: "image/example.jpg", offset: 0, bytes: 4, sha256: hash, pack: pack.file)
        XCTAssertThrowsError(try LessonMediaManifest(format: "sisu-lesson-media-v1", packs: [pack, pack],
            assets: [item], version: hash).validated())
        XCTAssertThrowsError(try LessonMediaManifest(format: "sisu-lesson-media-v1", packs: [pack],
            assets: [item, item], version: hash).validated())
        let overflow = LessonMediaItem(key: item.key, offset: Int64.max, bytes: 4, sha256: hash, pack: pack.file)
        XCTAssertThrowsError(try LessonMediaManifest(format: "sisu-lesson-media-v1", packs: [pack],
            assets: [overflow], version: hash).validated())
    }

    @MainActor
    func testEveryCatalogWordAndSentenceHasReadyMadeRecordings() throws {
        let url = try XCTUnwrap(Bundle.main.url(forResource: "lesson-media", withExtension: "json"))
        let catalog = try JSONDecoder().decode(LessonMediaManifest.self, from: Data(contentsOf: url)).validated()
        let seeds = try StudyStore.readSeeds()
        for seed in seeds {
            for (language, text) in [("en-US", seed.english), ("fi-FI", seed.finnish), ("fi-FI", seed.sentence)] where !text.isEmpty {
                XCTAssertNotNil(catalog.itemByKey[lessonRecordingKey(language: language, text: text)], "Missing \(seed.id): \(text)")
            }
        }
    }
}

// Run explicitly when validating a release; this suite uses the live Bluehost service.
final class HostedLessonMediaTests: XCTestCase {
    func testHostedImageAudioCacheAndDurableOfflinePack() async throws {
        let directory = URL.temporaryDirectory.appending(path: "HostedMedia-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: directory) }
        let bundle = Bundle.main
        let repository = try LessonMediaRepository(bundle: bundle,
            baseURL: URL(string: "https://essaykingapp.com/finnish3000/v1/")!, storageRoot: directory)
        let key = "image/fi-0316-r001.jpg"
        let image = try await repository.data(for: key)
        XCTAssertNotNil(UIImage(data: image))
        let audioKey = lessonRecordingKey(language: "fi-FI", text: "pullo")
        let audio = try await repository.data(for: audioKey)
        let player = try AVAudioPlayer(data: audio)
        XCTAssertTrue(player.prepareToPlay())
        XCTAssertGreaterThan(player.duration, 0)
        let cachedStatus = await repository.status()
        XCTAssertGreaterThanOrEqual(cachedStatus.cachedBytes, Int64(image.count + audio.count))

        let cachedOnly = try LessonMediaRepository(bundle: bundle,
            baseURL: URL(string: "https://example.invalid/")!, storageRoot: directory)
        let cachedImage = try await cachedOnly.data(for: key)
        XCTAssertEqual(cachedImage, image)

        let catalog = await repository.catalog
        let item = try XCTUnwrap(catalog.itemByKey[key])
        let pack = try XCTUnwrap(catalog.packByFile[item.pack])
        try await repository.download(pack, allowsCellular: true)
        let status = await repository.status()
        XCTAssertEqual(status.downloadedBytes, pack.bytes)
        let offline = try LessonMediaRepository(bundle: bundle,
            baseURL: URL(string: "https://example.invalid/")!, storageRoot: directory)
        let savedImage = try await offline.data(for: key)
        XCTAssertEqual(savedImage, image)
        try await offline.removeDownloadedMedia()
        let removed = await offline.status()
        XCTAssertEqual(removed.downloadedBytes, 0)
        XCTAssertEqual(removed.cachedBytes, 0)
    }
}
