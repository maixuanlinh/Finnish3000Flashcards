# Release notes and version policy

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
