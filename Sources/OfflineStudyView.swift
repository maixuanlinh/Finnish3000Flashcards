import SwiftUI

struct OfflineStudyView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(LessonMedia.self) private var media
    @AppStorage("offlineDownloadWiFiOnly") private var wifiOnly = true
    @State private var confirmRemoval = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 10) {
                        Image(systemName: media.status.isReady ? "checkmark.circle.fill" : "arrow.down.circle.fill")
                            .font(.system(size: 42)).foregroundStyle(Palette.forest)
                        Text(media.status.isReady ? "Ready for offline study" : "Download for offline study")
                            .font(.system(size: 28, weight: .semibold, design: .serif)).foregroundStyle(Palette.ink)
                        Text("Downloading the complete collection is convenient when you study without internet, but the images and pronunciation audio will occupy storage on this iPhone or iPad.")
                            .font(.subheadline).foregroundStyle(Palette.muted)
                    }

                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Label("Lesson media", systemImage: "photo.stack")
                                .font(.headline).foregroundStyle(Palette.ink)
                            Spacer()
                            Text(ByteCountFormatter.lessonMedia.string(fromByteCount: media.status.totalBytes))
                                .font(.subheadline.weight(.semibold)).foregroundStyle(Palette.forest)
                        }
                        ProgressView(value: media.status.progress).tint(Palette.forest)
                            .accessibilityIdentifier("offline.progress")
                        HStack {
                            Text(progressDescription).foregroundStyle(Palette.muted)
                            Spacer()
                            Text("\(Int(media.status.progress * 100))%")
                                .monospacedDigit().foregroundStyle(Palette.muted)
                        }.font(.caption)
                    }
                    .padding(19).background(.white, in: RoundedRectangle(cornerRadius: 23))

                    Toggle(isOn: $wifiOnly) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Download on Wi-Fi only").font(.headline).foregroundStyle(Palette.ink)
                            Text("Avoid using mobile data for the full collection.")
                                .font(.caption).foregroundStyle(Palette.muted)
                        }
                    }
                    .tint(Palette.forest).padding(18)
                    .background(.white, in: RoundedRectangle(cornerRadius: 23))
                    .disabled(media.isDownloading)
                    .accessibilityIdentifier("offline.wifiOnly")

                    VStack(alignment: .leading, spacing: 8) {
                        Label("No download is required to begin", systemImage: "sparkles")
                            .font(.headline).foregroundStyle(Palette.forest)
                        Text("Starter lessons are included. Other images and recordings load as you reach them and are cached locally, so the app becomes more useful offline over time.")
                            .font(.subheadline).foregroundStyle(Palette.muted)
                        Text("Saved while studying: \(ByteCountFormatter.lessonMedia.string(fromByteCount: media.status.cachedBytes)). Temporary files may be cleared by iOS when storage is low. Use the full download to keep the collection available offline.")
                            .font(.caption).foregroundStyle(Palette.muted)
                        Text("Keep the app open while downloading. You can study or move between tabs, then continue the download later if needed.")
                            .font(.caption).foregroundStyle(Palette.muted)
                    }
                    .padding(18).background(Palette.sage.opacity(0.55), in: RoundedRectangle(cornerRadius: 23))

                    if let message = media.message ?? media.status.error {
                        Text(message).font(.subheadline).foregroundStyle(media.status.isReady ? Palette.forest : Palette.clay)
                            .accessibilityIdentifier("offline.message")
                    }

                    if !media.isDownloading && media.status.storageUsedBytes > 0 {
                        Button("Remove offline download", role: .destructive) { confirmRemoval = true }
                            .frame(maxWidth: .infinity).accessibilityIdentifier("offline.remove")
                    }
                }
                .frame(maxWidth: 580).padding(22).frame(maxWidth: .infinity)
            }
            .background(Palette.background)
            .safeAreaInset(edge: .bottom) {
                if !media.status.isReady {
                    Button {
                        media.isDownloading ? media.pauseDownload() : media.startOfflineDownload(wifiOnly: wifiOnly)
                    } label: {
                        Label(media.isDownloading ? "Pause download" : hasOfflineProgress ? "Continue download" : "Download complete collection",
                              systemImage: media.isDownloading ? "pause.fill" : "arrow.down.circle.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(FilledActionStyle()).padding(16).background(Palette.background)
                    .disabled(media.status.loading || media.status.totalBytes == 0)
                    .accessibilityIdentifier(media.isDownloading ? "offline.pause" : "offline.download")
                }
            }
            .navigationTitle("Offline study").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } } }
            .task { await media.refresh() }
            .confirmationDialog("Remove downloaded lessons?", isPresented: $confirmRemoval, titleVisibility: .visible) {
                Button("Remove downloads", role: .destructive) { Task { await media.removeDownloads() } }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Your learning progress and personal artwork will be kept. Images and audio can load online again when needed.")
            }
        }
    }

    private var progressDescription: String {
        if media.status.isReady { return "Complete collection saved" }
        if media.status.partialBytes > 0 || media.status.downloadedBytes > 0 {
            return "\(ByteCountFormatter.lessonMedia.string(fromByteCount: media.status.remainingBytes)) remaining"
        }
        return "\(ByteCountFormatter.lessonMedia.string(fromByteCount: media.status.bundledBytes)) included with the app"
    }

    private var hasOfflineProgress: Bool {
        media.status.partialBytes > 0 || media.status.downloadedBytes > 0
    }
}

struct OfflineStudyRow: View {
    @Environment(LessonMedia.self) private var media
    let open: () -> Void

    var body: some View {
        Button(action: open) {
            HStack(spacing: 14) {
                Image(systemName: media.status.isReady ? "checkmark.circle.fill" : "arrow.down.circle")
                    .font(.title3).frame(width: 44, height: 44).background(Palette.sage, in: Circle())
                VStack(alignment: .leading, spacing: 4) {
                    Text("Download for offline study").font(.headline)
                    Text(media.status.isReady ? "Images and audio are ready offline" :
                            "Convenient offline learning · uses device storage")
                        .font(.caption).foregroundStyle(Palette.muted)
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.right").font(.caption.weight(.semibold))
            }
            .foregroundStyle(Palette.forest).padding(16)
            .background(.white, in: RoundedRectangle(cornerRadius: 23))
        }
        .buttonStyle(.plain).accessibilityIdentifier("progress.offlineStudy")
    }
}
