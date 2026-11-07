import CryptoKit
import Foundation
import Observation

private let hostedLessonMediaURL = URL(string: "https://essaykingapp.com/finnish3000/v1/")!

func lessonMediaHash(_ data: Data) -> String {
    SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
}

func lessonRecordingKey(language: String, text: String) -> String {
    "audio/\(language)/\(lessonMediaHash(Data(text.utf8)))"
}

struct LessonMediaPack: Decodable, Sendable {
    let file: String
    let bytes: Int64
    let sha256: String
    let starter: Bool
}

struct LessonMediaItem: Decodable, Sendable {
    let key: String
    let offset: Int64
    let bytes: Int
    let sha256: String
    let pack: String
}

struct LessonMediaManifest: Decodable, Sendable {
    let format: String
    let packs: [LessonMediaPack]
    let assets: [LessonMediaItem]
    let version: String

    func validated() throws -> LessonMediaCatalog {
        guard format == "sisu-lesson-media-v1", version.isSHA256,
              !packs.isEmpty, packs.count <= 200,
              assets.count >= 1, assets.count <= 20_000 else { throw LessonMediaError.invalidManifest }
        var packMap: [String: LessonMediaPack] = [:]
        for pack in packs {
            guard pack.sha256.isSHA256,
                  pack.file == "pack-\(pack.sha256).bin",
                  (1...12_000_000).contains(pack.bytes),
                  packMap.updateValue(pack, forKey: pack.file) == nil else { throw LessonMediaError.invalidManifest }
        }
        var itemMap: [String: LessonMediaItem] = [:]
        for item in assets {
            guard item.sha256.isSHA256, !item.key.contains(".."), !item.key.hasPrefix("/"),
                  (1...4_000_000).contains(item.bytes), item.offset >= 0,
                  let pack = packMap[item.pack], item.offset <= pack.bytes,
                  Int64(item.bytes) <= pack.bytes - item.offset,
                  itemMap.updateValue(item, forKey: item.key) == nil else {
                throw LessonMediaError.invalidManifest
            }
        }
        return LessonMediaCatalog(version: version, packs: packs, packByFile: packMap, itemByKey: itemMap)
    }
}

struct LessonMediaCatalog: Sendable {
    let version: String
    let packs: [LessonMediaPack]
    let packByFile: [String: LessonMediaPack]
    let itemByKey: [String: LessonMediaItem]
}

struct LessonMediaStatus: Equatable, Sendable {
    var totalBytes: Int64 = 0
    var bundledBytes: Int64 = 0
    var downloadedBytes: Int64 = 0
    var cachedBytes: Int64 = 0
    var partialBytes: Int64 = 0
    var readyPacks = 0
    var packCount = 0
    var loading = true
    var error: String?

    var isReady: Bool { !loading && packCount > 0 && readyPacks == packCount }
    var remainingBytes: Int64 { max(0, totalBytes - bundledBytes - downloadedBytes - partialBytes) }
    var storageUsedBytes: Int64 { downloadedBytes + cachedBytes + partialBytes }
    var progress: Double { totalBytes == 0 ? 0 : Double(bundledBytes + downloadedBytes + partialBytes) / Double(totalBytes) }
}

enum LessonMediaError: LocalizedError {
    case missingManifest, invalidManifest, unavailable, invalidResponse, verificationFailed, insufficientStorage

    var errorDescription: String? {
        switch self {
        case .missingManifest, .invalidManifest:
            "Lesson downloads could not be loaded. Please update the app and try again."
        case .unavailable:
            "This lesson is not available yet. Check your internet connection and try again."
        case .invalidResponse, .verificationFailed:
            "This lesson could not be verified. Check your connection and try again."
        case .insufficientStorage:
            "There is not enough free storage for the offline lessons. Free some space and try again."
        }
    }
}

private extension String {
    var isSHA256: Bool { count == 64 && allSatisfy { $0.isHexDigit && !$0.isUppercase } }
}

actor LessonMediaRepository {
    let catalog: LessonMediaCatalog
    let previewKeys: Set<String>
    private let bundle: Bundle
    private let baseURL: URL
    private let fullDirectory: URL
    private let cacheDirectory: URL
    private let session: URLSession
    private var verifiedPacks: [String: (size: Int64, modified: Date?)] = [:]

    init(bundle: Bundle, baseURL: URL, storageRoot: URL? = nil) throws {
        guard baseURL.scheme == "https", baseURL.user == nil, baseURL.password == nil else {
            throw LessonMediaError.invalidManifest
        }
        guard let manifestURL = bundle.url(forResource: "lesson-media", withExtension: "json") else {
            throw LessonMediaError.missingManifest
        }
        let manifest = try JSONDecoder().decode(LessonMediaManifest.self, from: Data(contentsOf: manifestURL))
        let loadedCatalog = try manifest.validated()
        catalog = loadedCatalog
        let freeKeys = try Self.freeAssetKeys(bundle: bundle)
        previewKeys = freeKeys
        guard !freeKeys.isEmpty, freeKeys.allSatisfy({ loadedCatalog.itemByKey[$0] != nil }) else { throw LessonMediaError.invalidManifest }
        self.bundle = bundle
        self.baseURL = baseURL
        fullDirectory = (storageRoot?.appending(path: "Saved") ?? URL.applicationSupportDirectory)
            .appending(path: "LessonMedia", directoryHint: .isDirectory)
            .appending(path: catalog.version, directoryHint: .isDirectory)
        cacheDirectory = (storageRoot?.appending(path: "Cache") ?? URL.cachesDirectory)
            .appending(path: "LessonMedia", directoryHint: .isDirectory)
            .appending(path: catalog.version, directoryHint: .isDirectory)
        let configuration = URLSessionConfiguration.default
        configuration.waitsForConnectivity = true
        configuration.timeoutIntervalForRequest = 20
        configuration.timeoutIntervalForResource = 90
        session = URLSession(configuration: configuration)
        try FileManager.default.createDirectory(at: fullDirectory, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        var values = URLResourceValues(); values.isExcludedFromBackup = true
        var full = fullDirectory; try? full.setResourceValues(values)
        var cache = cacheDirectory; try? cache.setResourceValues(values)
    }

    private struct PreviewArtwork: Decodable {
        let wordID: String
        let filename: String
        let thumbnailFilename: String
    }

    static func freeAssetKeys(bundle: Bundle) throws -> Set<String> {
        let decoder = JSONDecoder()
        func data(_ name: String) throws -> Data {
            guard let url = bundle.url(forResource: name, withExtension: "json") else { throw LessonMediaError.missingManifest }
            return try Data(contentsOf: url)
        }
        let starters = try decoder.decode([WordSeed].self, from: data("starter100"))
        let catalog = try decoder.decode(VocabularyCatalog.self, from: data("catalog3000"))
        let examples = try decoder.decode([SentenceSeed].self, from: data("examples3000"))
        let artwork = try decoder.decode([PreviewArtwork].self, from: data("manifest"))
        let overrides = Dictionary(uniqueKeysWithValues: starters.map { ($0.id, $0) })
        let sentences = Dictionary(uniqueKeysWithValues: examples.map { ($0.id, $0.sentence) })
        var ids: Set<String> = []
        var keys: Set<String> = []
        for entry in catalog.entries {
            let english = overrides[entry.id]?.english ?? entry.english
            guard PremiumAccess.isPreview(english) else { continue }
            ids.insert(entry.id)
            let finnish = overrides[entry.id]?.finnish ?? entry.finnish
            keys.insert(lessonRecordingKey(language: "en-US", text: english))
            keys.insert(lessonRecordingKey(language: "fi-FI", text: finnish))
            if let sentence = sentences[entry.id] { keys.insert(lessonRecordingKey(language: "fi-FI", text: sentence)) }
        }
        guard ids.count == 211 else { throw LessonMediaError.invalidManifest }
        for picture in artwork where ids.contains(picture.wordID) {
            keys.insert("image/" + picture.filename)
            keys.insert("image/" + picture.thumbnailFilename)
        }
        return keys
    }

    private func previewURL(_ item: LessonMediaItem) -> URL {
        fullDirectory.appending(path: "Preview").appending(path: item.sha256)
    }

    private func savedPreviewData(_ item: LessonMediaItem) -> Data? {
        guard let data = try? Data(contentsOf: previewURL(item)), data.count == item.bytes,
              lessonMediaHash(data) == item.sha256 else { return nil }
        return data
    }

    func previewMissingKeys() -> [String] {
        previewKeys.sorted().filter { key in
            guard let item = catalog.itemByKey[key], let pack = catalog.packByFile[item.pack] else { return true }
            return bundledURL(pack) == nil && verifiedFullURL(pack) == nil && savedPreviewData(item) == nil
        }
    }

    func downloadPreviewAsset(_ key: String, allowsCellular: Bool) async throws {
        // Never download a mixed whole pack for a free offline request.
        guard previewKeys.contains(key), let item = catalog.itemByKey[key] else { throw LessonMediaError.unavailable }
        let data = try await data(for: key, allowsCellular: allowsCellular)
        try Task.checkCancellation()
        let destination = previewURL(item)
        try FileManager.default.createDirectory(at: destination.deletingLastPathComponent(), withIntermediateDirectories: true)
        try data.write(to: destination, options: [.atomic])
    }

    private func previewStatus() -> LessonMediaStatus {
        var result = LessonMediaStatus(packCount: previewKeys.count, loading: false)
        for key in previewKeys {
            guard let item = catalog.itemByKey[key], let pack = catalog.packByFile[item.pack] else { continue }
            result.totalBytes += Int64(item.bytes)
            if bundledURL(pack) != nil {
                result.bundledBytes += Int64(item.bytes); result.readyPacks += 1
            } else if verifiedFullURL(pack) != nil || savedPreviewData(item) != nil {
                result.downloadedBytes += Int64(item.bytes); result.readyPacks += 1
            }
        }
        return result
    }

    func status(previewOnly: Bool = false) -> LessonMediaStatus {
        if previewOnly { return previewStatus() }
        var result = LessonMediaStatus(totalBytes: catalog.packs.reduce(0) { $0 + $1.bytes },
                                       packCount: catalog.packs.count, loading: false)
        for pack in catalog.packs {
            if bundledURL(pack) != nil {
                result.bundledBytes += pack.bytes; result.readyPacks += 1
            } else if verifiedFullURL(pack) != nil {
                result.downloadedBytes += pack.bytes; result.readyPacks += 1
            } else {
                result.partialBytes += min(fileSize(partURL(pack)), pack.bytes)
            }
        }
        result.cachedBytes = (try? FileManager.default.contentsOfDirectory(at: cacheDirectory,
            includingPropertiesForKeys: [.fileSizeKey], options: [.skipsHiddenFiles]))?.reduce(0) {
                $0 + Int64((try? $1.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0)
            } ?? 0
        return result
    }

    func data(for key: String, allowsCellular: Bool = true) async throws -> Data {
        try Task.checkCancellation()
        guard let item = catalog.itemByKey[key], let pack = catalog.packByFile[item.pack] else {
            throw LessonMediaError.unavailable
        }
        if let local = bundledURL(pack) ?? verifiedFullURL(pack) {
            return try read(item, from: local)
        }
        if let data = savedPreviewData(item) { return data }
        let cached = cacheDirectory.appending(path: item.sha256)
        if let data = try? Data(contentsOf: cached), lessonMediaHash(data) == item.sha256 { return data }
        try? FileManager.default.removeItem(at: cached)
        var request = URLRequest(url: baseURL.appending(path: pack.file))
        request.setValue("identity", forHTTPHeaderField: "Accept-Encoding")
        request.setValue("bytes=\(item.offset)-\(item.offset + Int64(item.bytes) - 1)", forHTTPHeaderField: "Range")
        request.allowsCellularAccess = allowsCellular
        let (data, response) = try await session.data(for: request)
        try Task.checkCancellation()
        try validate(response, expectedStart: item.offset, expectedEnd: item.offset + Int64(item.bytes) - 1,
                     total: pack.bytes, dataCount: data.count)
        guard data.count == item.bytes, lessonMediaHash(data) == item.sha256 else {
            throw LessonMediaError.verificationFailed
        }
        try data.write(to: cached, options: [.atomic])
        return data
    }

    func download(_ pack: LessonMediaPack, allowsCellular: Bool) async throws {
        if bundledURL(pack) != nil || verifiedFullURL(pack) != nil { return }
        let partial = partURL(pack)
        var start = min(fileSize(partial), pack.bytes)
        if start == pack.bytes {
            try finish(partial, pack: pack); return
        }
        var request = URLRequest(url: baseURL.appending(path: pack.file))
        request.setValue("identity", forHTTPHeaderField: "Accept-Encoding")
        request.setValue("bytes=\(start)-\(pack.bytes - 1)", forHTTPHeaderField: "Range")
        request.allowsCellularAccess = allowsCellular
        let (data, response) = try await session.data(for: request)
        try Task.checkCancellation()
        try validate(response, expectedStart: start, expectedEnd: pack.bytes - 1,
                     total: pack.bytes, dataCount: data.count)
        if start == 0 {
            try data.write(to: partial, options: [.atomic])
        } else {
            let handle = try FileHandle(forWritingTo: partial)
            defer { try? handle.close() }
            try handle.seekToEnd(); try handle.write(contentsOf: data)
        }
        start += Int64(data.count)
        guard start == pack.bytes else { throw LessonMediaError.invalidResponse }
        try finish(partial, pack: pack)
    }

    func missingPacks() -> [LessonMediaPack] {
        catalog.packs.filter { bundledURL($0) == nil && verifiedFullURL($0) == nil }
    }

    func removeDownloadedMedia() throws {
        if FileManager.default.fileExists(atPath: fullDirectory.path) {
            try FileManager.default.removeItem(at: fullDirectory)
            try FileManager.default.createDirectory(at: fullDirectory, withIntermediateDirectories: true)
        }
        if FileManager.default.fileExists(atPath: cacheDirectory.path) {
            try FileManager.default.removeItem(at: cacheDirectory)
            try FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        }
        verifiedPacks.removeAll()
        excludeFromBackup(fullDirectory)
        excludeFromBackup(cacheDirectory)
    }

    func availableCapacity() -> Int64 {
        (try? fullDirectory.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey])
            .volumeAvailableCapacityForImportantUsage) ?? 0
    }

    private func bundledURL(_ pack: LessonMediaPack) -> URL? {
        guard let url = bundle.url(forResource: pack.file, withExtension: nil), fileSize(url) == pack.bytes else { return nil }
        return url
    }

    private func fullURL(_ pack: LessonMediaPack) -> URL { fullDirectory.appending(path: pack.file) }
    private func partURL(_ pack: LessonMediaPack) -> URL { fullDirectory.appending(path: pack.file + ".part") }

    private func verifiedFullURL(_ pack: LessonMediaPack) -> URL? {
        let url = fullURL(pack)
        let values = try? url.resourceValues(forKeys: [.fileSizeKey, .contentModificationDateKey])
        let signature = (size: Int64(values?.fileSize ?? 0), modified: values?.contentModificationDate)
        guard signature.size == pack.bytes else { verifiedPacks.removeValue(forKey: pack.file); return nil }
        if let verified = verifiedPacks[pack.file], verified.size == signature.size,
           verified.modified == signature.modified { return url }
        guard let data = try? Data(contentsOf: url), lessonMediaHash(data) == pack.sha256 else {
            verifiedPacks.removeValue(forKey: pack.file); try? FileManager.default.removeItem(at: url); return nil
        }
        verifiedPacks[pack.file] = signature
        return url
    }

    private func finish(_ partial: URL, pack: LessonMediaPack) throws {
        guard fileSize(partial) == pack.bytes,
              lessonMediaHash(try Data(contentsOf: partial)) == pack.sha256 else {
            try? FileManager.default.removeItem(at: partial)
            throw LessonMediaError.verificationFailed
        }
        let destination = fullURL(pack)
        try? FileManager.default.removeItem(at: destination)
        try FileManager.default.moveItem(at: partial, to: destination)
        let values = try? destination.resourceValues(forKeys: [.fileSizeKey, .contentModificationDateKey])
        verifiedPacks[pack.file] = (Int64(values?.fileSize ?? 0), values?.contentModificationDate)
        for item in catalog.itemByKey.values where item.pack == pack.file {
            try? FileManager.default.removeItem(at: cacheDirectory.appending(path: item.sha256))
        }
    }

    private func read(_ item: LessonMediaItem, from url: URL) throws -> Data {
        let handle = try FileHandle(forReadingFrom: url)
        defer { try? handle.close() }
        try handle.seek(toOffset: UInt64(item.offset))
        guard let data = try handle.read(upToCount: item.bytes), data.count == item.bytes,
              lessonMediaHash(data) == item.sha256 else { throw LessonMediaError.verificationFailed }
        return data
    }

    private func validate(_ response: URLResponse, expectedStart: Int64, expectedEnd: Int64,
                          total: Int64, dataCount: Int) throws {
        guard let http = response as? HTTPURLResponse, http.statusCode == 206,
              http.value(forHTTPHeaderField: "Content-Range") == "bytes \(expectedStart)-\(expectedEnd)/\(total)",
              Int64(dataCount) == expectedEnd - expectedStart + 1 else { throw LessonMediaError.invalidResponse }
    }

    private func fileSize(_ url: URL) -> Int64 {
        Int64((try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0)
    }

    private func excludeFromBackup(_ url: URL) {
        var values = URLResourceValues()
        values.isExcludedFromBackup = true
        var mutableURL = url
        try? mutableURL.setResourceValues(values)
    }
}

@MainActor
@Observable
final class LessonMedia {
    static let shared = LessonMedia()

    private(set) var status = LessonMediaStatus()
    private(set) var premiumAccess = false
    private(set) var isDownloading = false
    private(set) var message: String?
    @ObservationIgnored private var repository: LessonMediaRepository?
    @ObservationIgnored private var downloadTask: Task<Void, Never>?
    @ObservationIgnored private var downloadGeneration = 0

    init(bundle: Bundle = .main, baseURL: URL = hostedLessonMediaURL) {
        do { repository = try LessonMediaRepository(bundle: bundle, baseURL: baseURL) }
        catch { status = LessonMediaStatus(loading: false, error: error.localizedDescription) }
    }

    func setPremium(_ value: Bool) async {
        if value != premiumAccess { pauseDownload() }
        premiumAccess = value
        await refresh()
    }

    func refresh() async {
        guard let repository else { return }
        status = await repository.status(previewOnly: !premiumAccess)
    }

    func data(for key: String) async throws -> Data {
        guard let repository else { throw LessonMediaError.missingManifest }
        let data = try await repository.data(for: key)
        status = await repository.status(previewOnly: !premiumAccess)
        return data
    }

    func startOfflineDownload(wifiOnly: Bool) {
        guard !isDownloading, let repository else { return }
        downloadGeneration += 1
        let generation = downloadGeneration
        message = nil; isDownloading = true
        downloadTask = Task { [weak self] in
            guard let self else { return }
            do {
                let current = await repository.status(previewOnly: !premiumAccess)
                let capacity = await repository.availableCapacity()
                if capacity > 0 && capacity < current.remainingBytes + 50_000_000 { throw LessonMediaError.insufficientStorage }
                if premiumAccess {
                    for pack in await repository.missingPacks() {
                        try Task.checkCancellation()
                        guard premiumAccess else { throw CancellationError() }
                        try await repository.download(pack, allowsCellular: !wifiOnly)
                        guard generation == downloadGeneration else { return }
                        status = await repository.status(previewOnly: !premiumAccess)
                    }
                } else {
                    for (index, key) in await repository.previewMissingKeys().enumerated() {
                        try Task.checkCancellation()
                        try await repository.downloadPreviewAsset(key, allowsCellular: !wifiOnly)
                        guard generation == downloadGeneration else { return }
                        if index % 20 == 0 { status = await repository.status(previewOnly: true) }
                    }
                }
                guard generation == downloadGeneration else { return }
                status = await repository.status(previewOnly: !premiumAccess)
                message = "Offline lessons are ready."
            } catch is CancellationError {
                if generation == downloadGeneration { status = await repository.status(previewOnly: !premiumAccess) }
            } catch {
                guard generation == downloadGeneration else { return }
                status = await repository.status(previewOnly: !premiumAccess)
                message = error.localizedDescription
            }
            if generation == downloadGeneration { isDownloading = false; downloadTask = nil }
        }
    }

    func pauseDownload() {
        downloadGeneration += 1
        downloadTask?.cancel(); downloadTask = nil; isDownloading = false
        Task { await refresh() }
    }

    func removeDownloads() async {
        pauseDownload()
        guard let repository else { return }
        do {
            try await repository.removeDownloadedMedia()
            status = await repository.status(previewOnly: !premiumAccess)
            message = "Downloaded lessons were removed."
        } catch { message = error.localizedDescription }
    }
}

extension ByteCountFormatter {
    static let lessonMedia: ByteCountFormatter = {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useGB]
        formatter.countStyle = .file
        return formatter
    }()
}
