# Prerecorded media and offline downloads — 28 October 2026

Current source replaces Android device TTS with generated MP3 playback and versioned media packs. The earlier voice-installation recovery notes below are historical and have been superseded.

The regular Android app now defaults to the live Bluehost media directory without extra Gradle flags. A normal `assembleDebug` produced package `com.linapps.ykiflashcards`, version `1.1-media-test`, **30,002,354 bytes**. Its 41 unit tests, lint (zero errors / 14 warnings), and content/pack hash audit passed. The preserved regular-app test APK is `build/media-release/finnish-words-app-test.apk`. The separate preview described below is optional; it is not the source of the media functionality. The Play release remains pending user testing.

- Generated **8,811 unique recordings** for all **9,000 Finnish-word, English-word and Finnish-sentence positions**. Audio: **124,841,948 bytes**. All **6,000** images/thumbnails converted to WebP with the original dimensions retained: **317,471,114 bytes**. Canonical Resources remain unchanged.
- Complete media: **442,313,062 bytes** (442.3 MB), in **60 immutable packs** of at most 8 MB. Starter media: **13,510,921 bytes**. Both app and public manifests reference version `c2764dfdd764d75d33dba84a1f026c2010d722a89435d921d64c35e4578fa7a5`.
- Independent media audit confirms every expected content mapping, all asset/pack SHA-256 checksums, contiguous pack boundaries, every image dimension, and decoding of 20 sampled MP3s. Automated checks establish integrity, not native pronunciation quality. Representative listening review is still needed before a production release.
- Full local verification: **41 unit tests passed**, zero failures/errors. Checks include interrupted/resumed downloads, cache reuse, no-range server fallback, corrupted packs, process-death recovery, insufficient storage, path/bounds validation, preservation of learning settings/personal files, and prefetching only the current and next three accessible cards. Existing domain, ViewModel, repository, artwork and reminder tests still pass. Artwork tests select a bundled image so the starter build does not depend on external hosting.
- Full offline debug build, test APK and lint build succeeded. Final lint: **zero errors / 14 warnings**, including a SharedPreferences style suggestion and existing dependency/style notices.
- Disposable API 34 emulator: actual English/Finnish recorded automatic playback of the apple lesson completed; learning ratings/events were unchanged; offline storage controls rendered correctly. The same scenario passed in both the full-offline installation and the starter-only installation. The initial test used an ambiguous library search and did not start playback; the final scenario selects the exact stable word ID.
- Starter-only debug installation: approximately **30.0 MB**; complete offline debug installation: approximately **458.8 MB**. These are measured development APKs, not final Play download estimates. Screen evidence: [starter controls](../../MediaDelivery/preview/offline-study-starter.png) and [full offline status](../../MediaDelivery/preview/offline-study-full.png).
- Bluehost deployment is live at **https://essaykingapp.com/finnish3000/install/**, with media at **https://essaykingapp.com/finnish3000/v1/**. Only the new `finnish3000` directory was extracted into the Essay King document root; temporary upload archives were moved to recoverable Trash after extraction. Existing WordPress files were not modified. No billing/subscription changes or paid speech-generation calls were made. No Play update has been published and no personal phone was changed.
- Public verification checked the exact manifest, lengths of all **60 packs**, HTTP **206** ranges and asset SHA-256 for images/Finnish/English audio, and a complete non-starter pack SHA-256. The hosted APK has the correct Android MIME type, **30,002,362 bytes**, and SHA-256 `c5bbbe43ef0958eef4104ba9b69a2cda79148e796310fa7ab1c9c80ea409c0b9`. Generated report: `build/media-release/hosting-verification.json`.
- Final phone preview package is `com.linapps.ykiflashcards.preview`, version `1.1-media-preview`, displayed as **3000 Finnish Words Preview**. It installs alongside the production Play app with separate progress. Existing purchases do not transfer into this development preview.
- The final preview passed **2 instrumentation checks** in the disposable API 34 emulator: a non-starter image downloaded, decoded and cached from live Bluehost and Finnish audio played through RecordedSpeech; automatic English/Finnish apple playback completed and the offline storage controls appeared with no learning-event or rating changes. Page evidence: [live installation page](../../MediaDelivery/preview/bluehost-install-page.png).

# Historical speech recovery verification — 28 October 2026

- `:app:testDebugUnitTest :app:lintDebug --offline`: **BUILD SUCCESSFUL** with 36 tests, zero failures/errors, and lint reporting zero errors / 13 warnings. No lint findings reference the modified speech or UI files.
- `:app:assembleDebug --offline`: **BUILD SUCCESSFUL**. Updated device-test package: `app/build/outputs/apk/debug/app-debug.apk`. This is a debug build, not a Play release.
- New coverage checks downloaded/offline voice selection, requested-language variants, failed initialization followed by a fresh attempt, missing Finnish voice followed by installation and successful retry, settings-screen fallback/restrictions, playback pause and retry without learning writes, manual Finnish pronunciation setup, and distinguishing other audio errors. Silent playback still makes no speech-session or pronunciation requests.
- Speech-engine tests use Robolectric; they verify requests and recovery rather than audible pronunciation. No Android device was connected. Finnish/English listening, manufacturer settings navigation and downloading voices on the affected Play installation still require a phone check. These source changes have not been published to Google Play.
- Setup instructions for the current Play app are in [the Android README](../README.md#if-play-asks-for-a-finnish-speech-voice).

# Android build-29 parity verification — 25 October 2026

Reference: iOS **1.0 (29)**, current Swift sources and commercial iPhone screenshots. Android **1.0.0-dev29 (2)**. This is a debug development build, not a Play release.

## Build and local checks

- `:app:assembleDebug :app:assembleDebugAndroidTest :app:testDebugUnitTest :app:lintDebug`: **BUILD SUCCESSFUL**. [Build log](parity-build29-build.log).
- **26 tests, zero failures**: 6 domain/playback, 9 ViewModel, 3 real SQLite/content, 5 reminder-planner, 3 real-decoder artwork/history/pack tests. JUnit results are in `app/build/test-results/testDebugUnitTest/`.
- Checks cover multi-level guarded undo, remaining-only playback/shuffle, independent library search and selected-word practice, detail reset to New, exact Known-word reminder routing with temporary language, access revocation, no auto-play ratings, Helsinki DST, shuffled reminder cycles, bounded image processing, invalid-image rollback, prompt/history persistence, compatible pack import/idempotence and unknown-ID rejection.
- Lint: **zero errors, 25 warnings**. Warnings cover dependency updates, platform ExifInterface, legacy backup/icon recommendations and Kotlin/Compose style suggestions. No lint baseline or suppressions were added.
- [Content audit](parity-build29-content.log): all 3,000 stable IDs/examples, 211 free A lessons and 6,000 bundled image files remain present. SHA-256 of every packaged canonical JSON, `artworkBriefs.json`, artwork manifest and JPEG matches the iOS resource source. No bundled images were regenerated or recompressed.

## Physical Samsung

Device: **Samsung SM-A546B, Android 14**. Installed by replacement with the same application ID and signing identity.

The five screen scenarios cover:

1. Reveal/hide prompt, Finnish answer, sentence and translation; open detail and illustration viewer.
2. Search the library, result count and practise exactly that selected word.
3. Swipe to Known and undo; verify stored review events and status return to the previous values.
4. Progress, reminder settings, Help/privacy and artwork editor navigation.
5. Silent automatic playback completion without rating/event writes; return to the manual card and retain it across rotation.

Result: **5 scenarios passed, zero failures**. [Final Samsung log](parity-build29-samsung-verified.log). The notification delivery/tap scenario runs separately in the disposable emulator so it does not change notification permissions on the personal phone. [Post-test data check](parity-build29-phone-data-check.json) confirms saved learning progress and review events were preserved, with database integrity `ok`.

Screenshots: [Samsung evidence](parity-build29-screenshots/samsung/parity-build29/). Visual inspection corrected a clipped illustration on the revealed study card. The answer image now fits its available space; short screens/large text can scroll.

## Emulator

Temporary API 34 Google APIs arm64 emulator, 1080×2340. The five screen scenarios passed. The independent notification test then passed **1 test, zero failures**, covering permission, scheduling, sample delivery, cold opening and warm reopening of the exact word, temporary prompt direction, one resumed app activity, unchanged saved direction and unchanged review events. [Final notification result](parity-build29-notification-verified.log).

The earlier combined emulator log (`parity-build29-emulator-verified.log`) retains a notification-test failure: an instrumentation process tried to send a background activity launch without the permission granted to an actual SystemUI notification tap. The final test emulates that authorized sender only inside the disposable emulator and uses lifecycle observation independently of Compose ActivityScenario. No production background-launch permission or lock-screen bypass was added.

## Data protection and test history

The initial Gradle connected test run failed because the Samsung was locked. Its automatic cleanup removed the app. Before cleanup, a local backup of the app's database/preferences/files was captured. The app was reinstalled and the backup restored; the restored learning database matched the backup byte-for-byte and passed SQLite `integrity_check`. Further physical-phone tests ran directly through the installed instrumentation package, which does not uninstall the app. Swipe tests undo their own events, playback tests restore their settings, and notification-permission changes are confined to the disposable emulator.

Earlier failed logs are retained: locked-screen/test-selector failures, transitional screenshots and the notification activity-lifecycle issue. Use the **final** logs/screenshots for the delivered build. Earlier 19 October validation remains in `validation.json` and describes the original iOS 0.21-based Android implementation.

## Remaining release/manual gates

- Configure the actual Google Play one-time product and app licensing public key; validate real Play test-track purchase/restore, pending, cancellation/refund and offline ownership. No actual payment was made and no invented price/product was used. Server-side verification and purchase lifecycle notifications remain release hardening.
- Listen to Finnish/English pronunciation with installed offline voices; calls/headsets, missing-voice recovery, real-world notification sound/Doze/reboot/timezone behavior and long-duration schedules still need manual hardware coverage.
- Exercise actual Photos/Files providers and cancellation, large/invalid images, sharing/export destinations, TalkBack, very large font settings, API 26 and tablets. Repository/decoder tests do not establish all provider behavior.
- Release signing, Android App Bundle/asset delivery and store-size acceptance remain separate. The debug package includes roughly 574 MiB of offline content/runtime; it is intended for sideload testing.

Platform behavior such as font rendering, system pickers, speech voices and Android's battery-delayed reminders cannot be pixel-identical to iOS. See [the parity review](PARITY.md) for the implementation contract and store configuration.
