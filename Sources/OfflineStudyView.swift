import SwiftUI

struct OfflineStudyView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(LessonMedia.self) private var media
    @Environment(PremiumStore.self) private var premium
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
                        Text(premium.isPremium ? "Save the complete collection’s images and pronunciation for studying without internet. Downloaded media occupies storage on this device." : "Save images and pronunciation for the 211 free A-set lessons. Upgrade to Premium for the full 3,000-word offline collection.")
                            .font(.subheadline).foregroundStyle(Palette.muted)
                    }

                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Label(premium.isPremium ? "Complete collection" : "Free A-set lessons", systemImage: "photo.stack")
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
                            Text("Avoid using mobile data for lesson downloads.")
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
                        Text(premium.isPremium ? "Starter lessons are included. Other images and recordings load as you reach them and are cached locally." : "Starter media is included. The free offline download saves only A-set images and recordings, including A lessons not bundled with the app.")
                            .font(.subheadline).foregroundStyle(Palette.muted)
                        Text("Saved while studying: \(ByteCountFormatter.lessonMedia.string(fromByteCount: media.status.cachedBytes)). Temporary files may be cleared by iOS when storage is low. Use the offline download to keep your available lessons saved.")
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
                        Label(media.isDownloading ? "Pause download" : hasOfflineProgress ? "Continue download" : premium.isPremium ? "Download complete collection" : "Download free A set",
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
            .task { await media.setPremium(premium.isPremium) }
            .onChange(of: premium.isPremium) { _, value in Task { await media.setPremium(value) } }
            .confirmationDialog("Remove downloaded lessons?", isPresented: $confirmRemoval, titleVisibility: .visible) {
                Button("Remove downloads", role: .destructive) { Task { await media.removeDownloads() } }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Your learning progress and personal artwork will be kept. Images and audio can load online again when needed.")
            }
        }
    }

    private var progressDescription: String {
        if media.status.isReady { return premium.isPremium ? "Complete collection saved" : "Free A set saved" }
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
    @Environment(PremiumStore.self) private var premium
    let open: () -> Void

    var body: some View {
        Button(action: open) {
            HStack(spacing: 14) {
                Image(systemName: media.status.isReady ? "checkmark.circle.fill" : "arrow.down.circle")
                    .font(.title3).frame(width: 44, height: 44).background(Palette.sage, in: Circle())
                VStack(alignment: .leading, spacing: 4) {
                    Text("Download for offline study").font(.headline)
                    Text(media.status.isReady ? "Your lessons are ready offline" : premium.isPremium ? "All 3,000 lessons · uses device storage" : "211 free A-set lessons · uses device storage")
                        .font(.caption).foregroundStyle(Palette.muted)
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.right").font(.caption.weight(.semibold))
            }
            .foregroundStyle(Palette.forest).padding(16)
            .background(.white, in: RoundedRectangle(cornerRadius: 23))
        }
        .buttonStyle(.plain).accessibilityIdentifier("settings.offlineStudy")
    }
}
