# 3000 Finnish Words for Android

## Production submission — 8 November 2026

Version **1.1.0 (6)** and the updated en-US listing were submitted together. Play Console confirmed **Changes in review**, with automated quick checks running. Managed publishing is off; the release targets a full rollout in the existing countries after approval. Eight current 1080×1920 phone screenshots replace the previous captures. Signing identity and existing Premium product IDs are preserved. See [release record](docs/PLAY-1.1.0-RELEASE.json) for bundle hashes and verification. Actual Play purchase/restore transactions were not repeated.

## Current checkpoint — 8 November 2026

Native Android **1.1.0-dev (3)** now follows **Finnish iOS 1.1.0 (38)**. Study has the bottom playback toolbar, visible English translations and Topic-first filters. Words has nine topic cards and seven smaller core word groups, with shared progress by stable word ID. The exact current list resumes after reopening. Progress contains learning history and resume; Settings contains downloads, Premium reminders and inline website/support/privacy links.

Free automatically downloads only the 211 complete A-set lessons over any connection. Premium gets a remembered English download choice, Wi-Fi control and reminders every 30 minutes/hour/two hours or custom times, with sleep hours and recurring delivery. WorkManager downloads run off the UI thread and can be paused. Each language keeps its own package, billing configuration, database, reviewed content, hosting and visual theme.

See [iOS 1.1.0 parity and verification](docs/IOS-1.1.0-PARITY.md). The older notes below are retained as history; their Progress/settings navigation and version numbers describe earlier builds. **Version 1.1.0 (6) was submitted to Google Play production review on 8 November 2026. It is not yet verified live.**

Follow-up [UI and functional parity audit](docs/IOS-1.1.0-PARITY-AUDIT.md): inline filter cards, direct More menu, complete reminder choices, topic progress/search recovery and remembered offline preferences.

Read-only topic membership check: `python3 tools/verify_ios_topics.py`.

---

The working source now uses **prerecorded Finnish/English audio and downloadable lesson media**. No Android speech engine or voice installation is needed. Generate the media before building; see [media generation and Bluehost delivery](../MediaDelivery/README.md). This change has not yet been published to Google Play. The build-29 parity notes below describe the preceding release.

Progress → **Download for offline study** offers an optional download with its actual size, Wi-Fi-only control, pause/continue and removal. Its subtitle explains that downloaded images and audio occupy storage. The same screen is linked from Playback settings. Starter lessons are included; other media loads online unless downloaded. Normal Android Studio and Gradle builds now use the verified Bluehost directory `https://essaykingapp.com/finnish3000/v1` by default. No special build flags are needed. An explicit `-PmediaBaseUrl=` bundles the complete collection for offline development testing.

The current Android update builds on **iOS 1.0, build 29**. Development version **1.1-media-test** (code 2); the normal application ID remains `com.linapps.ykiflashcards`. Prerecorded audio and media downloads are integrated into this regular app, including future Play builds. The optional `phonePreview` flag is only for the previously published separate preview.

Open this `Android` folder in Android Studio, let it sync, select `app` and your phone/emulator, then Run. Keep the adjacent `Resources` folder in place. Use the bundled JDK and Android SDK 36; minimum Android API 26.

The update aligns the Study, Words, detail and Progress screens and adds reminders, personal artwork/prompt histories, image import/export, prepared-pack import, help/privacy, and Google Play purchase integration. It also corrects remaining-card playback/shuffle, independent library search, multi-level undo and exact reminder routing.

See [the current parity review](docs/PARITY.md) and [verification](docs/VALIDATION.md) for evidence and outstanding device/store/release gates. Google Play product/public-key configuration is required before paid Android purchases can be tested; the default installation includes all basic words and the full free A set.

Build/check from this directory:

```sh
./gradlew :app:assembleDebug :app:testDebugUnitTest :app:lintDebug :app:assembleDebugAndroidTest
python3 tools/verify_content.py
```

The debug APK is `app/build/outputs/apk/debug/app-debug.apk`. It can update a development installation signed with the same debug key. A Play-installed app normally has a different signing key: test that update through a Play test track rather than uninstalling and losing progress. See the test-safety note in PARITY.md before running instrumentation. The historical notes below describe the initial implementation and are retained for context.

## If Play asks for a Finnish speech voice

This workaround applies to the existing Play version that uses Android TTS, not the new prerecorded-audio source.

The vocabulary is bundled with the app, but pronunciation uses downloaded voices from Android's selected text-to-speech engine. Some phones do not include Finnish in the default engine. Both automatic study and the individual pronunciation buttons need a Finnish voice; English prompt/answer audio also needs an English voice.

1. In Android Settings, search for **Text-to-speech** (on Samsung, usually under **General management → Text-to-speech output**).
2. Check the preferred engine. If it does not offer Finnish, select an installed engine that does, such as Google's speech engine.
3. Open the engine's settings, choose **Install voice data**, and download **Finnish / Suomi** and an English voice. This download needs an internet connection.
4. Return to the app and tap Play again. If using an older app version, reopen the app after changing the speech engine.

The new source replaces device-generated speech with prepared recordings. For silent automatic study, turn off all three reading switches in Playback settings.

---

# Sisu Cards for Android — first implementation

Native Kotlin / Jetpack Compose port alongside iOS 0.21. Full feature parity is **in progress**. The shipping access provider is Free; payments and subscriptions are deferred. There is no fake purchase flow or release unlock switch.

Start with [the implementation roadmap](docs/ROADMAP.md), [feature checklist](docs/PARITY.md), and [test results](docs/VALIDATION.md).

## Build and run

1. Open this `Android` folder in Android Studio. Use the bundled JDK (17 or later; this project was built with Android Studio's JBR), and install Android SDK 36. The parent `Resources` directory must remain beside `Android`.
2. Let Gradle sync. The included Gradle 8.13 wrapper pins AGP 8.13.2 and Kotlin/Compose compiler 2.0.21.
3. Select `app` and an API 26+ emulator or Android device, then Run. A Finnish offline TTS voice must be installed for audio; silent study needs no speech engine or network.

From this folder:

```sh
./gradlew :app:assembleDebug :app:testDebugUnitTest
python3 tools/verify_content.py
```

Set `JAVA_HOME` to Android Studio's bundled JDK if your default JDK is incompatible. Set `ANDROID_HOME` or your own untracked `local.properties` SDK path. The debug APK is `app/build/outputs/apk/debug/app-debug.apk`. Build assets are generated from the original iOS resources; all 3,000 JPEGs and thumbnails are included. Allow roughly 3 GB for build intermediates. This is a large sideload development package; Play distribution and asset-delivery sizing are outstanding release work.

## Architecture

`domain` holds immutable word/filter/rating models, English dictionary sorting, access policy and the cancellable playback cycle. `data` holds a constructor-injected repository, transactional SQLite progress/event storage, settings, lazy Android speech and an observable entitlement interface. `StudyViewModel` owns a StateFlow and user actions; Compose collects it with lifecycle awareness. A small application container supplies dependencies. The UI has no SQL or store billing calls.

Canonical content loads on an IO dispatcher and is joined by stable IDs, preserving starter overrides and current sentence translations. Content is never written over learner progress. Ratings and history commit in one SQLite transaction; undo checks both the exact latest event and review count/date. Private progress/settings survive app updates; uninstall clears them. Backup is disabled until backup/privacy behavior has been designed. This port does not import an existing iPhone's learning history.

EntitlementRepository exposes Unknown/Free/Complete; AccessPolicy gates complete lessons and automatic selections. Replace the provider in SisuApplication with a verified Play adapter later. Do not replace this with a saved premium Boolean. A lessons remain complete; B–Z basic pairs, manual ratings and word pronunciation stay available. The existing iOS product is a one-time non-consumable, not a subscription.

## Manual test pass

- Launch offline. See 3,000 vocabulary entries with all-word filters, and 211 when English letter A is selected. English X has no entries.
- Study: reveal/hide, English/Finnish direction, left/right swipe and rating buttons, undo, shuffle, empty-filter state and completed-selection restart.
- Words: search `omena`, `apple`, or sentence text, combine letter/topic/status filters, practise list, open a detail and rate there. Check the study queue respects the new status.
- Kill/relaunch: ratings, review history, direction and playback settings remain; study queue deliberately restarts. Rotation retains ViewModel state and pauses audio.
- A lesson: image, memory hook, Finnish sentence and smaller English translation; zoom, pan, pinch/double-tap and back. B lesson: basic pair and Finnish word audio available, complete content hidden, no purchase button.
- Progress: known/learning/new counts total 3,000, daily/weekly history, goal 10 and Keep practising.
- Automatic A study: all-silent mode; each audio toggle; slow/natural/brisk; recall/post-audio timing; pause/resume replays prompt; previous/next skip without counting; completion/replay; Stop restores manual queue. Ratings/history must remain unchanged.
- Pause by tab switch, detail, filters, settings, Home/lock or audio-focus loss. Missing offline Finnish/English voices show a recoverable message. Retry after installing voices or disable audio.
- Test a small phone, tablet, Android 13+ and API 26, large text and TalkBack before release. Reminder and personal artwork tests will become available as those phases are implemented.
