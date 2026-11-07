# Release notes and version policy

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
