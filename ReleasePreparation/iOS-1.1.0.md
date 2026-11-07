# 3000 Finnish Words — iOS 1.1.0 (37)

Prepared 7 November 2026. Git checkpoint: `ios-v1.1.0-rc.1`.

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
| Offline download | A set | Entire collection |
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

## Local artifacts

- Archive: `build/Commercial/Finnish3000-1.1.0-build37.xcarchive`
- Signed App Store IPA: `build/Commercial/Export-1.1.0-build37/SisuCards.ipa`
- IPA size: **25,470,699 bytes**; Apple determines actual device download size.
- IPA SHA-256: `214e62cce5b9baea51455205372f80cd655d11350a2260c8ac9ad4b808fdccf8`
- Verified deep code signature, distribution profile, debugger disabled, app/version identity and included privacy manifest. Export completed successfully after a transient App Store Connect network warning.
- Archive and IPA stay local, outside Git. Release-configured customer app installed and opened on the physical iPhone.

## Remaining before public release

1. Test this candidate through TestFlight with a sandbox account, including purchase, cancel and restore. Also update an actually purchased older installation in place and confirm Premium and learning history remain available. Local tests cover the entitlement contract but cannot prove a real account’s historical receipt migration.
2. Verify the current App Store Connect version, listing/screenshots and hosting/privacy declarations. This run did not access or change the store account; historical local release-status notes are not a current store-status check.
3. Upload and review the concrete candidate, then submit/release through the existing store record. No upload or submission was performed in this checkpoint.

Android parity and physical Android testing are deferred until an Android device is available. Swedish parity follows the accepted Finnish implementation; neither platform was changed in this checkpoint.
