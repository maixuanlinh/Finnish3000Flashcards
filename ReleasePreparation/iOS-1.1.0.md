# 3000 Finnish Words — iOS 1.1.0 (38)

Prepared 7 November 2026. Source checkpoint: `ios-v1.1.0-rc.2`. Submission checkpoint: `ios-v1.1.0-submitted`.

**Submitted 7 November 2026 at 22:40 EET. Current observed status: Waiting for Review. Automatic release after approval is selected.** Apple submission ID `14ade235-71d3-4ea1-ac91-86a94b74777c`. [Review record](https://appstoreconnect.apple.com/apps/6826695314/distribution/reviewsubmissions/details/14ade235-71d3-4ea1-ac91-86a94b74777c).

## Identity and existing buyers

| Item | Existing release / candidate |
| --- | --- |
| App display name | 3000 Finnish Words |
| Bundle ID | `com.linapps.ykiflashcards` |
| Premium product | `com.linapps.ykiflashcards.complete` |
| Purchase type | Non-consumable, one-time unlock |
| App Store record | Existing record; no replacement app created |

The archive’s bundle ID and name were compared with build 30. Startup reads the existing verified StoreKit entitlement; Restore Purchases uses the same product. Existing buyers receive all Premium features without purchasing again. No progress migration, identifier change or database reset is introduced. Personal remains a separate bundle and was not replaced.

## Customer behavior

| Feature | Free | Premium, including existing owners |
| --- | --- | --- |
| Basic vocabulary / word pronunciation | All 3,000 words | All 3,000 words |
| Complete illustrated lessons | 211 A-set lessons | All 3,000 lessons |
| Offline download | A set saves automatically, Wi-Fi/mobile data | One-time optional full download; Wi-Fi / current connection / Later |
| Word reminders | Upgrade required | Repeating schedule and sleep hours |
| Automatic study | Free A-set route | Full collection |

## Validation evidence

- Physical iPhone: baseline customer suite, 63 passes and one system notification-permission skip. Two customer Settings UI tests passed.
- Changed Premium suite: 8 passes, including delayed verified entitlement and an already purchased account at startup, without calling purchase again.
- Local StoreKit: purchase, new store instance, restore, refund, pending approval, cancellation and failure covered by 4 passing tests.
- Three Premium UI flows passed: Free lesson restrictions and rating, purchase/relaunch/restore/refund, and Free A-set autoplay.
- After the final menu change, customer purchase/restore/refund, Free A-set playback/stop, Free reminder/offline restrictions and the two-item menu/inline Settings all passed on iPhone.
- Final menu/Settings flow passed on the 13-inch iPad simulator. iPad uses the system’s top tab bar.
- Content validator: 3,000 unique IDs with Finnish/English examples, translations and active artwork; no missing examples or translations. Structural validation is not a linguistic review.
- Genuine app captures are tracked in `CommercialValidation/Screenshots/release-1.1.0-*.png`; Premium captures use local test transactions, not real charges.

A local StoreKit transaction returned success approximately one second before `currentEntitlements` became available. The purchase flow now retries the verified entitlement check up to ten times, 300 ms apart; it does not grant access merely because a purchase button was tapped. [Apple’s currentEntitlements documentation](https://developer.apple.com/documentation/storekit/transaction/currententitlements).

## English offline onboarding and background transfers — build 38

The automatic Free path downloads only the 211 A-set lesson assets (about 32 MB beyond the starter media), including on mobile data. It never queues a mixed full pack. Premium users are asked once on first use, including existing purchasers; new purchasers are asked after their purchase sheet closes. Later and interactive dismissal are remembered. Downloading can continue while studying or switching tabs, with a progress link in Study and controls in Settings. Explicitly pausing/removing Free downloads disables automatic restart until the user chooses to download again.

Background URLSession tasks retain their exact verified range requests and persistent plan. iOS controls their background timing. Force-quitting can stop transfers; on reopening, the app reconciles pending tasks and missing verified files. Hash validation and filesystem work run off the main actor. Networking is low priority with a two-connection host limit. Existing completed files are kept across pauses and app updates; the content manifest is unchanged. A full collection download reuses existing whole saved packs; assets previously saved individually for Free are cleaned up as their full packs are saved to avoid keeping both copies.

Ten retained media/policy unit checks passed. Physical-iPhone UI checks passed for automatic Free download during usable study, pause/relaunch, existing Premium prompt/Later/relaunch, and the prompt after a successful new purchase. Test media and preferences are isolated; Premium is granted only through local verified StoreKit transactions in those tests.

A separate real-profile check left the app via Home for approximately 12 seconds. Its banner was at 7% before leaving. After returning, all **1,034 missing Free files, 31,932,680 bytes**, were present. Saved names and sizes exactly matched the catalog; **622 files have modification times between Home and reactivation**. Each save validates SHA-256. This check did not rate any word or reset the learning store. This is observed successful background delivery, not a promise about iOS scheduling on every device/network.

Screens: [English Premium prompt](../CommercialValidation/Screenshots/offline-premium-first-download-prompt.png), [after upgrade](../CommercialValidation/Screenshots/offline-prompt-after-upgrade.png), [study and progress](../CommercialValidation/Screenshots/offline-auto-free-while-studying.png), [download controls](../CommercialValidation/Screenshots/offline-free-download-progress.png).

## Local artifacts

- Archive: `build/Commercial/Finnish3000-1.1.0-build38.xcarchive`
- Signed App Store IPA: `build/Commercial/Export-1.1.0-build38/SisuCards.ipa`
- IPA size: **25,587,472 bytes**; Apple determines actual device download size.
- IPA SHA-256: `5d36851b0a1613e760573017498247d0e62bbad9651c7f9c1086f020a76cd707`
- Verified deep code signature, distribution profile, debugger disabled, app/version identity and included privacy manifest. Export completed successfully. Build 38 supersedes build 37 and was uploaded successfully for this submission; build 37 was not uploaded.
- Archive and IPA stay local, outside Git. Release-configured customer app installed and opened on the physical iPhone.

## Submission outcome and remaining external steps

- Apple processing completed and version **1.1.0 (38)** was attached to the existing record. The unsubmitted 1.0.1 draft/build 31 was replaced; no live release or pending screenshot experiment was withdrawn.
- Saved accurate English description/release/review text, retained existing marketing screenshots/video and the approved Complete product, and set the marketing URL to the current landing page. [Exact saved metadata and status](AppStore-1.1.0-en-US.json).
- App Store Connect accepted **one App Version item** and shows **Waiting for Review**. Automatic public release after approval is selected. Apple's approval and actual store availability remain external steps; they were not observed during this run.
- Existing privacy/account declarations were viewed and retained. Hosting retention was not independently inspected in this run, and the published privacy label was not changed or newly attested.
- This submission did not include a TestFlight/sandbox purchase or an upgrade from an actually purchased older installation. Local StoreKit, entitlement startup/restore tests, unchanged identifiers and phone testing are the validation evidence available.


Android parity and physical Android testing are deferred until an Android device is available. Swedish parity follows the accepted Finnish implementation; neither platform was changed in this checkpoint.
