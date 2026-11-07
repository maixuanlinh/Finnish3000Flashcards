# 3000 Finnish Words

## Current development checkpoint — 7 November 2026

The iOS topic-browser update targets **1.1.0 (31)**; the personal phone build is **0.22.0 (23)** and keeps `com.finnishcards.SisuCards` to preserve installed progress. Git tag: `ios-v1.1.0-dev.1`. This is a development checkpoint, not an App Store/Google Play submission. See [release notes and version policy](RELEASES.md).

Words now opens a phone-sized browser of nine YKI themes plus Everyday essentials. Each word retains its original ID and learning record across every topic. Study and Words share topic, status and letter filters. Android's saved media/offline-study work is included; the new topic browser is currently iOS-only.

The media manifest and two starter packs are tracked under `MediaDelivery/generated/assets/`, so native builds work from a fresh checkout. Full media generation and hosting remain separate. The snapshot and validation notes below describe earlier releases.


## GitHub source snapshot — 25 October 2026

Repository: `maixuanlinh/Finnish3000Flashcards`. This snapshot contains the native SwiftUI iOS app (version 1.0, build 30), the native Kotlin/Jetpack Compose Android app including its current Play distribution configuration, and their shared lesson media. The internal project and application identifiers remain unchanged to preserve existing installs.

The iOS build 30 starter uses the same immutable Bluehost media collection as Android at `https://essaykingapp.com/finnish3000/v1/`. Only 13.5 MB of starter media ships in the app. Other images and Finnish/English recordings load on demand, validate SHA-256 checksums, and cache locally. **Progress → Download for offline study** saves the full 442.3 MB collection (about 428.8 MB additional download), with Wi-Fi-only, pause/continue and removal controls. Keep the app open for the complete download; completed packs survive relaunch. Learning progress is independent of downloaded media. Pronunciation uses prerecorded MP3s, with no device voice installation required.

The signed build 30 archive contains a 35.1 MiB app and exports to a 25,261,162-byte IPA (about 25.3 MB). These are local measurements; Apple determines the final per-device App Store download size. `project.yml` and the checked-in Xcode project both include only the manifest and starter packs from `MediaDelivery/generated/assets`, plus artwork metadata; they exclude the full `Resources/BundledArtwork` image folder and duplicate `artworkBriefs.json`.

Validation on 28 October 2026: 54 unit/integration tests passed, one notification-permission test skipped, plus the final commercial screen and hosted media tests passed. The hosted test checks WebP/MP3 decoding, on-demand cache reuse without network, a complete verified pack, relaunch/offline reuse, and removal. Every catalog word and Finnish example has a recording key. The separate StoreKit transaction fixture is still blocked by the Simulator service (`SKInternalErrorDomain` / `notEntitled`); live price lookup works, but a physical TestFlight purchase/restore check remains outstanding. No iPhone was connected during this validation.

To run the offline-safe suite, select `SisuCardsTests` and skip `StoreKitPremiumTests` plus `HostedLessonMediaTests`. Run `HostedLessonMediaTests` explicitly with a working connection for release validation; it downloads one approximately 8 MB pack into a disposable test folder. Run `CommercialReleaseTests/testCommercialScreensHelpAndStoreOffer` for the customer screens and live price lookup.

The repository includes all 3,000 English–Finnish entries, Finnish examples and English translations, 3,000 full-size mnemonic images with thumbnails, editable artwork briefs, app icons, tests, content verification tools, store-listing assets, and iPhone/iPad design reference screenshots in `CommercialValidation/Screenshots/`. Android reads the adjacent `Resources/` directory; keep this folder layout intact.

For iOS, open `SisuCards.xcodeproj` and select **3000 Finnish Words**. Use **3000 Finnish Words Local Purchases** for the bundled StoreKit fixture and **3000 Finnish Words Personal** for the existing personal configuration. Choose your own signing team when building on another Mac. `project.yml` is the XcodeGen source for the checked-in project. For Android setup, build commands, and remaining release checks, see [Android/README.md](Android/README.md).

Run `python3 Tools/validate_content.py` and `python3 Android/tools/verify_content.py` from the repository root to verify the shared catalog and artwork. The latter also verifies APK asset hashes when a local debug APK is present.

Build products, device backups, workstation paths/settings, signing keys, credentials, and private store-account evidence stay local. Most `CommercialValidation/` files referenced in the historical notes below are intentionally excluded; they are not build inputs. Signing and live store configuration must be supplied separately for distribution. The separate `Swedish3000/` React Native prototype is excluded from this Finnish baseline. Earlier release names, schemes, pricing notes, and store-status statements below document development history; use the snapshot instructions above for the current checkout.

Current commercial display name and scheme: **3000 Finnish Words**. App Store subtitle: **Flashcards for YKI practice**. Version 1.0/build 30; bundle/product IDs and public website URLs retain their existing values. Personal configuration keeps the installed Sisu Cards identity. Build 30 has been uploaded and processed; version 1.0 and the first Premium IAP are together in a Ready for Review draft. The old build 29 submission was withdrawn. Final resubmission is pending verification of Bluehost access-log retention and the corresponding App Store privacy disclosure. See `CommercialValidation/RELEASE-STEPS.md` for local release evidence; older names and status notes below are historical.

Current App Store Connect setup: YKI Flashcards has a free download price and a €11.99 one-time Complete unlock configured (Finland base; regional equivalents). It remains unpublished and untested against the live sandbox. See `CommercialValidation/RELEASE-STEPS.md` for current status; older release notes below are historical.

# YKI Flashcards — native iOS and Android projects

The commercial app is now **YKI Flashcards**, with bundle/package ID `com.linapps.ykiflashcards` and one-time Premium product `com.linapps.ykiflashcards.complete`. The confirmed pricing is free download plus €11.99 one-time Premium. Product registration and price setup in the stores are separate steps; local fixtures do not establish a live price.

Use **YKI Flashcards** for commercial Release builds, **YKI Flashcards Local Purchases** for local payment testing, and **YKI Flashcards Personal** for personal access. The Personal configuration deliberately retains `com.finnishcards.SisuCards` and its existing display name so an update preserves the installed private copy's data. The commercial identity installs as a separate app and does not automatically import personal progress.

The internal Xcode target/module remains SisuCards; legacy artwork-pack formats and stored notification identifiers are preserved for compatibility. These internal names are not the store listing or app identifier. No official YKI affiliation or verified exam syllabus alignment is claimed.

The original development history below uses the former Sisu Cards name. Current release instructions: `CommercialValidation/RELEASE-STEPS.md`.

---

# Sisu Cards — iOS version 0.21

Native SwiftUI Finnish flashcards with **3,000 words, 3,000 Finnish example sentences with English translations, and 3,000 reviewed illustrations**, all available offline. Requires iOS 17 or later. No external app dependencies.

## Run on your iPhone

1. Open `SisuCards.xcodeproj` in Xcode and select the **SisuCards** scheme.
2. Connect and unlock your iPhone, select it as the destination, and choose your Apple development team under **Signing & Capabilities**.
3. Press **Run** (⌘R). Enable Developer Mode on the phone if Xcode requests it.

The saved team is preserved. This is a development app. Local StoreKit purchase testing is configured; live App Store products and distribution are not configured. Updating preserves stable word IDs and learning history. This package has not been installed on a physical phone automatically.

## Personal use before the store launches

Choose **SisuCards Personal** in Xcode’s scheme menu (next to the Run button), select your iPhone, and press **Run**. This installs a development build with all 3,000 complete lessons, artwork, examples, sentence speech, automatic study and premium reminder artwork available without a purchase or App Store Connect product. Progress identifies it as **SisuCards Personal**; its collection screen has no price retry or restore action.

Personal access is compiled into the **Personal** build configuration, not stored in a preference or supplied through a launch environment variable. It therefore works when reopening the installed build from the Home Screen, including offline. Development signing still applies; if the provisioning expires, rebuild/reinstall from Xcode.

This scheme uses the same bundle identifier and storage as the current iOS app to retain local learning history when updated with the same signing team. **Install over the existing app; do not delete it first.** Personal and customer copies replace one another on a device. Returning to the normal scheme restores normal verified purchase access; personal use does not create store ownership. Learning data is separate from access, and is not reset by switching configurations.

For customer testing use **SisuCards** (normal StoreKit access) or **SisuCards Local Purchases** (simulated purchases). The Personal scheme’s **Archive** and **Profile** actions use **Release**, which excludes personal access; its regular Test action uses Debug for the customer regression suite. The personal-only checks can be run explicitly with `-configuration Personal`, selecting `PersonalAccessTests` and `PersonalAccessFlowTests`. Do not manually archive the Personal configuration for distribution.

## Study

Swipe left for **Still learning**, right for **I know it**, and undo a rating when needed. Tap the word area or full-width bottom bar to flip. The arrow beside the pronunciation button opens the same Word detail screen as the Words tab. A separate centered button below the detail image opens full-screen zoom; no control covers the picture or its sentence. Swiping the study image does not open a viewer. Pinch or double-tap the full-screen picture to zoom. Ratings made in Word detail update the Study queue when you return, respecting the selected learning filter.

English dictionary order is the default. One **Filters** panel combines learning status, starting letter and topic across Study and Words. Search English, Finnish or example text, practise a filtered list, shuffle, switch prompt language and track progress. Finnish speech uses an available device voice.

Every illustrated answer includes the Finnish word, English meaning, example and an appropriate memory cue or scene. Sound and spelling mnemonics are memory aids, not pronunciation guides or etymologies. The native word and sentence remain accessible as real text. Each unlocked Study lesson shows a direct English translation immediately below the Finnish sentence, in a smaller, muted subtitle. The same translation is always visible in the sentence section of Word detail, with no extra tap. Flipping back hides the answer and its sentence pair together.

Navigation uses an ID index rather than repeatedly scanning the full collection. Letter initials are indexed once, filter counts are shared across the A–Z controls in one pass, and Words reuses text-search matches. Artwork metadata is decoded before navigation on a background task; image reading and display preparation run away from the UI thread, with canceled requests prevented from replacing a newer card. Image frames stay stable while loading. Pronunciation initializes when requested.

## Automatic study

Tap **Play**, immediately before the three-dot menu on Study, to start with the saved settings. Choose **Playback settings** in that menu to adjust the recall pause and pause after audio (1–15 seconds each), read the prompt/answer/Finnish sentence independently, or choose Slow/Natural/Brisk speech. Turning all three audio switches off enables silent automatic reveal. The Start button remains visible at the bottom of the settings screen.

Playback uses the current filtered selection and English/Finnish prompt direction. It waits for the question audio to finish, allows recall time, reveals the answer, waits for enabled answer/sentence audio to finish, then pauses before advancing. Previous, Play/Pause, Next and Stop replace the rating row while automatic study is active. **Stop** returns to the untouched manual queue. Resume restarts the current card from its prompt. At the end, Play starts the selection again.

During playback, the counter records distinct completed cards; skipped cards are not counted. Playback never changes Known/Learning status or creates review-history entries. A deliberate manual swipe still records a rating and returns to manual study. Changing tabs, leaving the app, opening filters/details/settings or an audio interruption pauses playback. This release supports foreground playback; locking the phone pauses it. Speech voices are provided by the device. A missing voice shows a recoverable message; silent playback remains available. Pronunciation initializes only when audio is requested.

Automatic study is included free for the A set. Playing a selection that includes locked lessons opens Premium; **Study the free A set** changes to the A filter, then Play starts it. All-word automatic study requires Premium.

## Word reminders

Open **Progress → Word reminders**. Reminders are off by default. Choose one, two, or four daily reminders, or edit up to four local times; select All words, Still learning, or New & learning, with an optional English starting letter. Choose a Finnish question, English question, or bilingual word pair. The target word appears in uppercase for emphasis, including Finnish Ä and Ö. Artwork thumbnails use the current personal image if available, otherwise the bundled picture. iOS makes its own thumbnail from the existing 768-pixel image so an expanded notification remains readable. The optional sound is the system chime; notifications do not automatically speak words. Device speech is available after opening the card.

Tap **Save reminders** to enable the schedule. The iOS permission prompt appears only when enabling reminders or explicitly sending a sample, never at launch. If permission was denied, use **Open iPhone Settings**, allow notifications, then return and save. **Send sample in 5 seconds** tests delivery without enabling a daily schedule. The on-screen preview shows the selected question and artwork; the system controls the actual banner/lock-screen image layout. On iOS 26.5, long-press the compact banner to see the attached image and **Practise word** action. Artwork can contain the answer; turn off the thumbnail for an unaided recall question.

Local notifications work offline and are delivered by iOS even when SisuCards is closed. No Firebase, remote push entitlement, server, login, or background timer is used. A rolling fourteen-day queue contains up to 56 shuffled word reminders plus a final refresh invitation. Opening the app refills the queue. New word content is not scheduled indefinitely if the app is never reopened. Focus, Scheduled Summary, notification permissions and system preferences control presentation. Significant time changes and foregrounding rebuild the schedule in the current local timezone.

Tapping a word reminder opens **that exact card**, including Known words, independently of the current topic/letter/status filter. The session prompt follows the notification's language without changing the saved study direction. Cold-launch notification destinations wait for the vocabulary to finish loading. Opening or dismissing a reminder does not rate the word or change progress. Disabling reminders removes SisuCards' pending reminder requests; unrelated app notification requests are left alone. Invalid or missing artwork falls back to a text reminder and is reported in settings. Images are attached through disposable copies; the original bundled/imported images are never moved or modified.

Word reminders stay free across all words. Free users receive A-set artwork; Premium adds artwork to B–Z reminders. Pending reminders are rebuilt when access changes, and delivered SisuCards notifications are removed on access loss so paid artwork does not remain in Notification Center. Android remains future work.

## Premium and local purchase testing

All **3,000 basic word pairs, manual flashcards, word pronunciation, search, filters, ratings, progress and text word reminders remain free**. Every English A entry (211 words) includes its complete illustration, memory hook, Finnish example, English translation, sentence pronunciation and automatic study. A single non-consumable purchase unlocks those complete lessons across B–Z and automatic playback for any selection. The free sample follows the A filter; it is not a separate 200-item list.

For a safe local purchase demo, select **SisuCards Local Purchases** in Xcode, then Run. This scheme attaches `StoreKit/SisuCards.storekit` to the Debug launch and shows **Local purchase test · No real charge** on the Premium screen. The local product is **com.finnishcards.sisucards.complete**, type **Non-Consumable**, with a test price of 11.99 and Finland storefront. The interface always displays the localized price returned by StoreKit. Use **Progress → Explore Premium** or a locked lesson to buy. **Restore Purchases** is available in Progress and the upgrade screen, even if the price cannot load.

The normal **SisuCards** scheme has no local StoreKit configuration. Before sandbox testing, create the matching product ID in App Store Connect and complete Apple's paid agreement, banking/tax and product setup. No live product has been created or submitted by this update. App Store Connect is not needed for the local demo. Android billing will be a separate implementation and product; purchases do not transfer between the stores.

Access is based on StoreKit 2 verified current entitlements and transaction updates. There is no persisted `isPremium` preference, app login, purchase backend, subscription, or release-build unlock switch. StoreKit's cached verified entitlement allows offline use; price loading and purchase restoration require store connectivity. Cancellation, pending approval, unavailable products and failures do not unlock content. Refund/revocation relocks complete lessons and stops automatic playback. A fresh app instance restores ownership from Apple independently of local learning history. Uninstalling may remove progress, personal artwork and reminder settings.

The `.storekit` configuration is a project file and test-bundle resource only; it is excluded from the shipping app bundle. The test-mode banner is Debug-only and does not grant access. Automated purchase tests use Apple's `SKTestSession`, not an app-side Premium bypass.

**Simulator note:** the installed iOS 26.5 runtime hits Apple's documented `SKInternalErrorDomain Code=3` local StoreKit test issue. Local purchase tests pass on the installed iOS 18.3 simulator. Use that runtime for automated purchase checks if 26.5 cannot load the local products. The app itself still builds against the current SDK.

## Artwork and storage

All 3,000 selected pictures are bundled as 768-pixel JPEGs with 160-pixel thumbnails in `Resources/BundledArtwork`. Their manifest preserves each selected revision's actual prompt and memory hook. The bundled artwork and metadata occupy **594.4 MB**. See `BundleValidation.json` for the measured unsigned app size for this release. These are measured local sizes, not App Store download estimates.

The separate `SisuArtwork` library retains original PNGs, all revisions, exact prompts, a SQLite registry and per-letter review galleries. They are not included in the app download. Existing A–I selected images are preserved unchanged. English X has no source entries.

To refresh the complete bundled selection from that adjacent library, use `python3 Tools/bundle_artwork.py`. The downloaded project already contains everything needed to build; no refresh or image import is required.

Personal pictures still override bundled art. In a word's **Artwork** editor, copy its prompt, generate in your ChatGPT session, then choose the saved image from Photos or Files. Prompt and image history preserve previous versions. **Use original card** restores the bundled picture. Per-word exports and prepared-pack imports remain available. The app does not synchronize ChatGPT conversations or require an API key.

Imports are downsampled to JPEG, stored as local files and indexed in SwiftData. Personal history adds storage and has no deletion control in this release. Back up important originals before removing the app. The 500-word/150 MB prepared-pack limit remains unchanged; no additional base64 packs were generated for J–Z.

## Content and verification

`Resources/catalog3000.json` contains source entries and Finnish equivalents; `examples3000.json` supplies the current Finnish examples and their English translations; `starter100.json` retains original starter metadata; `artworkBriefs.json` supplies editable fresh prompts. Stable IDs preserve learning progress when content changes. `ContentChanges-v0.16.json` records the audited sentence and translation updates applied during J–Z production. Historical validation reports remain available.

Examples use dictionary forms when natural and the necessary Finnish inflection otherwise. Each card illustrates one sense where several translations are listed. All 3,000 current Finnish examples have direct English translations. The 2,885 distinct Finnish sentences were translated individually; repeated Finnish sentences reuse the same translation. Where Finnish uses the gender-neutral pronoun *hän*, English generally uses singular *they*. `SentenceTranslations-v0.18.json` is a reviewable record of each word ID, Finnish sentence and English translation. Both the complete catalog and the original 100 starter rows stay synchronized. Installing this update refreshes sentence translations without resetting ratings, review dates or history. Topics beyond the original starter collection remain under Vocabulary.

All pictures were visually checked in groups of at most ten. The review checked Finnish text, meaning, memory links, relevant quantities and visual consistency. Failed versions remain in the library history. This is agent editorial review; independent Finnish editorial and commercial rights review remain separate before publishing a paid course. The English-derived source is not a verified Finnish frequency ranking or official YKI syllabus.

Version 0.19 has 33 distinct passing checks across this update, including 26 database/playback unit checks and 7 interface checks. Final playback checks passed on iPhone 17 Pro and iPhone SE; the audio-switch check also passed. Earlier simulator automation and audio/timing failures are retained in the reports. It adds focused automatic-study checks for audio sequencing, completion, cancellation, pause/resume, skipping, reverse prompt language, voice failure, selected-word playback, tab changes and returning to manual study without changing Known status. `Validation.json` contains the actual run results, including card-layout and sentence-translation regressions. All five canonical content/metadata JSON files remain byte-for-byte unchanged from 0.18; no images were regenerated or recompressed.

Version 0.17's navigation optimizations remain in place. Its 3,000-ID lookup plus one complete filter-summary workload averaged about 6.4 ms on the iPhone 17 Pro / iOS 26.5 simulator, excluding store/index setup. This measures processing, not total transition animation time or physical-iPhone performance. `PerformanceValidation-v0.17.json` records all ten samples. `Preview/27-study-sentence-translation.png` and `Preview/28-detail-sentence-translation.png` show the sentence subtitles. New automatic-study screenshots are recorded in `Validation.json`. Prior screenshots and validation reports are retained. Physical-phone installation and native photo/file picker selections were not automated.

The source ZIP is checked by CRC and by the SHA-256 of every included file. Full artwork-history checks also verify all registered revision files and database integrity. `Validation.json`, `BundleValidation.json`, `ContentValidation.json` and `ArtworkValidation-v0.16.json` hold the results. Use **Product → Test** in Xcode to run the full suite.

Study, progress and imported artwork work offline. Generating new art needs connectivity. Cloud sync, purchases and spaced repetition remain future work.

## v0.20 verification

Fourteen reminder unit/integration checks passed, covering shuffled pools, local/DST times, preference persistence, permission handling, request cancellation, safe artwork copies and native system attachment storage. Four distinct interface checks passed, including existing card/automatic-playback checks, reminder settings and a real local notification after app termination. The final notification opens the exact Finnish card and preserves the existing Known count. Final readable expanded artwork was visually reviewed.

There were 35 test executions during this update: 34 passed and one historical failure was corrected. That initial test incorrectly assumed an empty persistent simulator store; it now compares existing progress before and after the cold launch without resetting anything. Final verification reran all 14 reminder checks and the native notification interface check successfully. The unsigned physical-iPhone build passed; no installation or notification delivery on a physical iPhone was attempted.

## v0.21 verification

Twenty-three distinct checks passed on iPhone SE / iOS 18.3: ten access/purchase checks (including four actual StoreKit integration scenarios), six existing playback-engine checks, the uppercase notification payload and native attachment round-trip checks, and five interface checks. Purchase unlock, fresh app-instance restore, pending approval, cancellation, failure, live refund, free A-set playback, B-set locks, manual ratings and closed-app notification routing were verified. Automated StoreKit dialogs are disabled only in test fixtures; the local Run scheme retains the system confirmation dialog.

One initial notification UI check tapped near the fixed footer on the small screen; it now scrolls the sample above the Save button and passes. The iOS 26.5 attempt was stopped because of the documented StoreKit simulator error; it is not counted as successful purchase evidence. The iOS 18.3 expanded notification screenshot showed text only, while the actual system round-trip retained the attached image bytes; presentation depends on the simulator/OS. The earlier iOS 26.5 artwork rendering evidence remains in Preview.

The unsigned iPhone **Release** build passed. All 3,000 images, vocabulary pairs and Finnish/English sentence pairs are preserved; source and built resource hashes match. The release app contains neither a `.storekit` file nor the StoreKitTest framework. No physical-phone installation, live App Store purchase, App Store Connect setup or Android implementation was performed.

## Android implementation

The native Kotlin / Jetpack Compose app in [Android](Android/README.md) has been updated against **iOS 1.0, build 29**. Its study, library, detail and progress screens now follow the current iOS layout, with reminders, artwork/prompt histories, image import/export, prepared-pack import, help/privacy and Google Play purchase integration. It retains the same offline vocabulary and artwork. See the [current parity review](Android/docs/PARITY.md) and [validation results](Android/docs/VALIDATION.md) for verified behavior and outstanding store/device/release gates. Paid Android purchases require the actual Google Play product and licensing public-key configuration. The iOS 0.21 verification history above describes that earlier iOS release.

## Phone-only development and storage

As of 25 October 2026 this project targets physical iOS devices only (`SUPPORTED_PLATFORMS = iphoneos`). Debug and Personal build only the connected architecture, use DWARF without an extra dSYM bundle, and disable SwiftUI previews. Release retains its normal symbol settings for distribution.

Use **SisuCards Personal → Linh Tiger iPhone → Run** for personal practice; use **SisuCards → your iPhone** for customer behavior. Simulator device data and the old iOS 18.3 runtime were removed during cleanup. Xcode 26.5's asset compiler also requires a current iOS runtime even when compiling for a physical phone: a phone build without one failed with “No available simulator runtimes for platform iphonesimulator.” Keep only the matching current iOS component installed as a build dependency; no simulator tests are needed for this workflow. Avoid downloading older or additional platform runtimes.

Xcode still needs some temporary build storage, and it may download debugging support again when the phone's OS changes. The currently connected iPhone 16 Plus's support files were retained to avoid an immediate multi-gigabyte download. An initial app build also packages the roughly 594 MB offline artwork. Avoid running multiple build configurations simultaneously or creating separate temporary DerivedData locations. Xcode's standard DerivedData can be cleared when builds are stopped; keep archives/dSYMs for shipped versions.

To restore simulator testing later, add `iphonesimulator` to `SUPPORTED_PLATFORMS` in `project.yml`, regenerate with XcodeGen, and create a virtual device using the current runtime. The retained runtime is required for compilation; virtual devices and their app data are separate and remain unnecessary for phone-only testing.

## Commercial release preparation — 25 October 2026

The normal SisuCards / Release archive is at `build/Commercial/SisuCards.xcarchive`; it excludes personal access and local StoreKit test resources, includes dSYMs and a required-reason privacy manifest, and passed local signature/content checks. This is a development-signed archive pending App Store distribution validation/export, not an uploaded or approved release. The confirmed model is free download plus €11.99 one-time Premium; no live price has been saved. See `CommercialValidation/RELEASE-STEPS.md` and `CommercialValidation/validation.json` for account setup order and remaining release blockers. The personal phone installation was not replaced.
