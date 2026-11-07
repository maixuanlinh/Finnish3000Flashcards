# Release notes and version policy

## ios-v1.1.0-submitted — 7 November 2026, 22:40 EET

**1.1.0 (38) submitted to Apple; Waiting for Review.** Automatic release after approval is selected. This is a submitted update, not a claim that version 1.1.0 is already live. The previously distributed version is 1.0 (30).

- Upload succeeded and Apple processing completed. Attached build `d9b65eef-d5cf-410d-8a8e-bc60c7ef09de` (38) to version 1.1.0, replacing the unused build 31 in the unsubmitted 1.0.1 draft.
- Saved the English description, What's New and review notes for topics, saved sessions, Settings, Free automatic offline media, Premium downloads/reminders and preserved existing Premium access. Updated Marketing URL to the current landing page. Kept existing screenshot/video assets and the pending product-page-optimization submission unchanged.
- Verified the existing `com.linapps.ykiflashcards.complete` non-consumable remains Approved. No new product, pricing, app identity or purchase migration was introduced. Existing privacy, content-rights and account declarations were retained; no new legal agreement was accepted.
- Submitted one App Version item. Apple submission ID: `14ade235-71d3-4ea1-ac91-86a94b74777c`.

[Review status](https://appstoreconnect.apple.com/apps/6826695314/distribution/reviewsubmissions/details/14ade235-71d3-4ea1-ac91-86a94b74777c), [submission screenshot](CommercialValidation/Screenshots/appstore-1.1.0-waiting-review.png), [saved listing text](ReleasePreparation/AppStore-1.1.0-en-US.json). TestFlight purchase/restore and a real purchased-version upgrade were not performed in this submission checkpoint; prior physical-device/local-StoreKit validation remains documented below.

## ios-v1.1.0-rc.2 — 7 November 2026

Customer release candidate **1.1.0 (38)**. Final Release installed/opened on the owner’s iPhone; refreshed signed App Store IPA exported locally. Personal configuration **0.23.5 (30)** remains separate. No upload or store submission.

- Automatically save the 211 A-set Free lessons over Wi-Fi or mobile data. No first-launch decision or wait screen is required. Existing starter assets and verified saved files are reused.
- Offer Premium users one English download sheet: **Download on Wi-Fi**, **Download now** (including mobile data), or **Later**. Existing Premium buyers see it once if needed; newly upgraded users see it after closing the purchase sheet. Dismissing the sheet counts as Later. Settings remains available afterward.
- Use persistent iOS background download tasks, a saved plan, exact verified byte ranges, low-priority networking, SHA-256 validation and background-session completion handling. Queue downloads off the main actor, retaining completed files. Stop Premium transfers when access is revoked. Resume paused requests without discarding their session progress when scope/network policy is unchanged.
- Keep Study usable and display a compact download-status row. Add English progress/waiting messages and controls in Settings. Remember explicit Free pause/removal, and avoid downloading the collection every day or asking again after Later.
- Keep the app identity, Premium product, word IDs and learning schema unchanged. Automated onboarding checks use isolated media/preferences and local StoreKit purchases.

Validation: ten relevant media/policy unit checks passed, three distinct iPhone onboarding UI flows passed (automatic Free study/pause/relaunch; existing Premium Later/relaunch; new purchase then offline prompt), and a real customer-profile background check passed. The phone saved all **1,034 additional Free media files (31,932,680 bytes)**; names/sizes exactly matched the manifest. File timestamps show **622 files saved while the app was offscreen**, before returning to it. Saving validates each file hash. The live check never rated or reset learning data. iOS scheduling and force-quit behavior still limit background execution; continuous execution is not promised.

[English Premium prompt](CommercialValidation/Screenshots/offline-premium-first-download-prompt.png), [prompt after upgrading](CommercialValidation/Screenshots/offline-prompt-after-upgrade.png), [study during download](CommercialValidation/Screenshots/offline-auto-free-while-studying.png), [download controls](CommercialValidation/Screenshots/offline-free-download-progress.png). [Candidate details](ReleasePreparation/iOS-1.1.0.md).

## ios-v1.1.0-rc.1 — 7 November 2026

Customer iOS release candidate **1.1.0 (37)**, named **3000 Finnish Words**. Archive and App Store distribution IPA exported and verified locally; Release installed on the owner’s iPhone. No upload, store metadata changes or submission. Personal configuration **0.23.4 (29)** remains separate.

- Preserve `com.linapps.ykiflashcards` and the existing non-consumable `com.linapps.ykiflashcards.complete`. Previously purchased Premium remains full Premium, including reminders and full offline downloads, with no second purchase. No learning schema or word IDs changed.
- Fix verified-purchase entitlement propagation: check the current entitlement again for up to 2.7 seconds while the purchase UI remains busy. This addresses the reproduced local StoreKit delay without granting access to cancelled, pending or unverified purchases.
- More contains only Shuffle this session and Show Finnish first / Show English first. Playback settings remains in the bottom toolbar; Return to manual study moves into that settings sheet.
- Verify the actual customer Free/Premium experience, including Free A-set offline access and Premium reminders. No Personal unlock or preview bypass is included in the Release build.

Validation: 63 offline unit/integration tests passed with one notification-permission check skipped in the baseline customer run; the changed Premium suite then passed all 8 unit tests and 4 real local-StoreKit tests. Three customer Premium UI flows passed. Final menu/Settings, Free restrictions and playback-stop changes passed on the physical iPhone; the inline menu/Settings flow also passed on a 13-inch iPad simulator. Structural content validation covers all 3,000 entries, illustrations and bilingual examples. App Store IPA signature, identity, version, privacy manifest and distribution profile were verified. TestFlight/App Store transactions and an upgrade from an actually purchased older installation remain to be checked before public release; local StoreKit tests do not replace those checks.

[Free lesson](CommercialValidation/Screenshots/release-1.1.0-free-word.png), [Premium lesson](CommercialValidation/Screenshots/release-1.1.0-premium-word.png), [Premium restored](CommercialValidation/Screenshots/release-1.1.0-premium-restored.png), [two-item menu](CommercialValidation/Screenshots/release-1.1.0-study-menu.png), [iPad Settings](CommercialValidation/Screenshots/release-1.1.0-ipad-settings.png). Details: [iOS release preparation](ReleasePreparation/iOS-1.1.0.md).

## ios-v1.1.0-dev.6 — 7 November 2026

Settings and Study menu refinement. iOS target **1.1.0 (36)**; Personal **0.23.3 (28)**. Development checkpoint; no store submission.

- Remove Still learning / I know it from the Study More menu. Swipes and VoiceOver rating actions remain available.
- Place Visit our website, Help & support, Privacy policy and version details directly in Settings. Remove the separate Help and privacy sheet.
- Keep one **Report a problem** email action for bugs and feedback, with the support address visible and a draft containing the app version. No separate feature-request button. The Premium support link opens the same email draft.
- Use the configured landing page at https://yki.essaykingapp.com/ and retain the existing published privacy-policy URL. Hosting returned HTTP 406 to scripted landing-page checks; live website navigation and sending email require manual confirmation.

Validation: focused physical-iPhone UI test passed, checking the remaining Study menu, absent rating buttons, direct Settings links and absence of the old support sheet. Test uses isolated learning data; no live email is sent. [Website and report action](CommercialValidation/Screenshots/settings-website-and-report.png), [inline privacy](CommercialValidation/Screenshots/settings-inline-privacy.png), [Study menu](CommercialValidation/Screenshots/study-menu-without-rating-actions.png).

## ios-v1.1.0-dev.5 — 7 November 2026

Study prototype refinement for owner review. iOS target **1.1.0 (35)**; Personal **0.23.2 (27)**. No store submission.

- Remove the English-subtitle button from the bottom Study toolbar. Available English example translations are always shown on the answer card, including when the obsolete subtitle preference was previously off. Premium lesson access remains unchanged.
- Reorder the shared Study/Words filter sheet to Learning status → Topic → English starts with. Filter selections and result-count logic are unchanged.
- Keep the list header, counter, swipe ratings, Undo and playback controls from the prototype.

Validation: both focused physical-iPhone UI flows passed. They verify that the subtitle toggle is absent and English translations remain visible even with the obsolete preference set to off, plus swipe/Undo, playback, toolbar safe areas and Topic appearing above English starts with. [Answer and toolbar](CommercialValidation/Screenshots/study-toolbar-always-english.png), [filter layout](CommercialValidation/Screenshots/filters-topic-before-letter.png).

## ios-v1.1.0-dev.4 — 7 November 2026

Status: **Study controls prototype for owner review**, not a store submission. iOS target **1.1.0 (34)**; Personal **0.23.1 (26)**.

- Keep the active list name, word counter and filter button at the top of Study. Topic lists show their Finnish title; filtered selections and learning lists retain appropriate names.
- Replace the visible Still learning / I know it row with compact Undo, Play/Pause, Playback settings, English subtitles and More controls. The row sits above the bottom tabs and retains their safe area.
- During automatic study, expose previous/next controls in the same row. Stop is available in More; the toolbar remains a single row.
- Preserve swipe ratings, Undo, playback and saved-session behavior. Alternative ratings remain in More and as accessibility actions. The subtitle control hides or shows the English sentence translation; Finnish examples remain visible.

Validation: **33 checks passed** on the physical iPhone 16 Plus: 30 study-store/playback tests and three UI flows covering swipe/Undo, English subtitles and automatic controls, and exact study-session recovery after relaunch. Geometry checks verify that the header, card, toolbar and bottom tabs do not overlap and that toolbar targets remain at least 44 points. Existing learning IDs and prior review history were preserved after reopening the owner app. Existing App Store/Play builds are unchanged.

Actual phone screenshots with temporary test data: [prompt](CommercialValidation/Screenshots/study-toolbar-prototype-prompt.png), [answer](CommercialValidation/Screenshots/study-toolbar-prototype-answer.png), and [automatic playback](CommercialValidation/Screenshots/study-toolbar-prototype-playback.png).

## ios-v1.1.0-dev.3 — 7 November 2026

Status: iOS development checkpoint for owner testing. Customer target **1.1.0 (33)**; Personal **0.23.0 (25)**. No store submission. Android remains at the previous checkpoint.

- Save the active study list, remaining order, filters and position across relaunch. Progress shows **Continue your last session** and **Currently learning**, with quick access to saved learning words. Reminder deep links do not replace the main saved session.
- Add **Settings** as a fourth tab. Move membership/purchases, offline downloads, word reminders and help there; Progress focuses on learning.
- Require verified Premium access to enable or sample reminders. Revocation disables and cancels reminders, including in-flight scheduling, while preserving learning data. The personal owner build retains Premium access.
- Free offline downloads save only images and recordings for the **211 A-set lessons**, using per-asset verified byte ranges. Premium retains full-pack downloads for all lessons. The free path cannot fetch paid assets or mixed full packs.
- Support every **30 minutes**, hourly, every 2/3/4 hours, or custom times, with local sleep/wake hours. Daily repeating triggers have no end date; assigned words repeat until the app reshuffles them on foregrounding. No remote push backend or guaranteed changing content while terminated is claimed. Samples are explicit five-second test alerts.
- Preserve legacy reminder settings, word IDs, review history, imported artwork and installed bundle identities. New schedules default to hourly with sleep from 22:00 to 08:00.

Validation: **67 checks passed** on the physical iPhone 16 Plus: 63 offline app tests, one live A-set asset download/reopen-without-network test, and three UI flows covering Settings/sleep hours, exact study-list recovery after relaunch, and the free reminder paywall/A-set download screen. Development tests use temporary learning stores and isolated reminder preferences. Live purchase/restore and real scheduled-notification delivery were not exercised in this checkpoint; scheduling, cancellation, quiet hours and Premium gates were tested against an isolated notification center.

After reopening the installed Personal app normally, all 3,000 learning records and all prior review events matched the pre-update backup exactly. No learning history, artwork or installed identity was reset. Private database snapshots remain local.

Reviewed phone screenshots use temporary test data: [Progress and saved session](CommercialValidation/Screenshots/settings-progress-session-iphone.png), [Settings tab](CommercialValidation/Screenshots/settings-tab-iphone.png), [sleep-hour schedule](CommercialValidation/Screenshots/settings-reminders-sleep-iphone.png), [free A-set download](CommercialValidation/Screenshots/settings-free-a-set-iphone.png), and [Premium reminder upgrade](CommercialValidation/Screenshots/settings-free-reminder-upgrade-iphone.png).

## ios-v1.1.0-dev.2 — 7 November 2026

Status: development checkpoint for owner testing. iOS target **1.1.0 (32)**; Personal **0.22.1 (24)**. No store submission.

Replace the 1,391-word Everyday essentials card with seven separately selectable collections under **Everyday word groups**. Switch between **YKI topics** and **Word groups** at the top of Words:

| Collection | Words |
| --- | ---: |
| Everyday verbs — Arjen verbit | 247 |
| Thinking & communication verbs — Ajattelun ja viestinnän verbit | 152 |
| Adjectives — Adjektiivit | 294 |
| Adverbs — Adverbit | 150 |
| Grammar & linking words — Kielen perussanat | 170 |
| Time, numbers & colours — Aika, luvut ja värit | 110 |
| Everyday nouns & ideas — Arjen substantiivit | 267 |

The seven collections partition 1,390 entries without duplicates. The remaining entry, **bicycle**, now correctly belongs to Travel & transport: its starter headword differed from the catalog's “bicycle / bike” spelling and previously fell into the catch-all list. Situational topic membership and per-word learning records are preserved.

Word groups use the entry's representative learning sense; a polysemous entry can include other grammatical senses. Months are matched case-sensitively, so **May** and the modal **may** remain separate. A regression test enforces complete coverage, no duplicates and a maximum of 300 words in each core collection.

Validation: all **23 vocabulary/store tests** and the focused physical iPhone 16 Plus UI test passed. They cover the group-size limit, coverage, May/may distinction, search, filtered practice and shared progress. The installed Personal app was reopened normally; every learning record and review event matched the pre-update backup. [Phone screenshot](CommercialValidation/Screenshots/core-word-groups-iphone.png).

## ios-v1.1.0-dev.1 — 7 November 2026

Status: development checkpoint for owner testing; no store release was submitted by this change.

| Component | Version | Build | Scope |
| --- | --- | --- | --- |
| iOS customer target | 1.1.0 | 31 | Next topic-browser release candidate source |
| iOS Personal | 0.22.0 | 23 | Owner's existing Sisu Cards installation |
| Android | Existing 1.0 Play / 1.1 media development variants | Existing Gradle values | Media and offline-study checkpoint; topic UI not yet ported |

### Topic browser

- Nine situational YKI themes plus Everyday essentials, with Finnish titles, English subtitles, topic icons and live known-word progress.
- Two-column cards on typical phones and one column at accessibility text sizes or narrow widths; the entire screen scrolls.
- Topic detail lists, search, status/letter filtering, and practice of the exact selected word list.
- Overlapping topic membership uses one existing learning record per vocabulary ID. Overall progress counts each word once; no database schema migration or progress reset.
- Membership is an initial editorial classification of the existing catalog. General actions, descriptions, quantities and function words default to Everyday essentials. Further linguistic review can refine membership without changing progress.

### Earlier work now saved

Commit `1d079bb` checkpoints previously uncommitted prerecorded media, on-demand caching, offline downloads, Android entitlement/playback work, website changes, store marketing source and their tests. The immutable media manifest and starter packs are included for reproducible native builds. Full generated media, personal backups, signing material and private account evidence remain outside tracked source.

### Validation

- Physical iPhone 16 Plus: the broader offline suite passed all 55 tests, including 22 vocabulary/store tests covering topic overlap, search counts, undo and persistence across catalog updates. Live StoreKit, hosted-network media and the system notification-permission test were excluded from this offline run.
- Physical iPhone 16 Plus: topic browsing, in-topic search, filtered practice, empty state/reset, and all ten cards passed a focused UI test; screenshots were visually reviewed.
- Android: 44 unit tests passed and the debug APK built successfully.
- Canonical content verification: 3,000 stable word IDs, bilingual examples, artwork pairs, the 211 free A lessons, and bundled media checksums passed.
- Website JavaScript syntax checks passed.

The initial physical-device UI attempts exposed ambiguous iOS tab accessibility matches; the test selector was corrected and the final run passed. App Store/Play purchase flows, new store submissions and the Android topic port are not part of this checkpoint.

Screenshots (temporary test data): [topic library](CommercialValidation/Screenshots/topics-library-iphone.png), [home vocabulary](CommercialValidation/Screenshots/topics-home-iphone.png), [remaining topic cards](CommercialValidation/Screenshots/topics-lower-iphone.png).

## Version policy

- Keep `project.yml` and the checked-in Xcode project versions identical. Never change bundle IDs to deliver an update.
- Increment the customer iOS build for each new binary; increment its marketing version for a user-facing release. Personal versions are tracked separately.
- Android version codes remain monotonically increasing within each package. Preview, personal and production packages have separate release histories; never replace a production package with a preview identity.
- Tag testable development checkpoints as `ios-vX.Y.Z-dev.N` or `android-vX.Y.Z-dev.N`. Reserve stable tags for verified releases; record store submission/approval separately.
- Before pushing a tag, commit source and release notes, run the relevant checks, and verify the remote branch/tag match the local commit. Keep credentials, device backups and private account evidence out of Git.
