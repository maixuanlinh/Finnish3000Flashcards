# YKI 3000 landing page

Live on Bluehost: **https://yki.essaykingapp.com/**. Dedicated document root: `/home3/maixuanl/public_html/yki3000`. The existing domain supports the subdomain; no new domain purchase is needed.

English page with Finnish and Swedish study options. Buildless HTML/CSS/JS; no external fonts, tracking, forms or backend. `.htaccess` redirects HTTP to HTTPS while allowing certificate validation requests.

## Structure

1. **Introduction:** choose Finnish or Swedish. A single action leads to the two language cards, where visitors choose a store.
2. **Screenshot carousel:** real screenshots inside CSS phone mockups, with a second preview behind the active phone. Five Finnish screens cover Android study, search, progress, reminders and the iOS lesson view. The Swedish selection shows a labelled iOS development screenshot. No Swedish Android screenshot is presented as available. Manual arrows, dots, keyboard navigation and touch swipes; no automatic rotation.
3. **Two language cards:** Finnish and Swedish, each with official Apple App Store and Google Play badges. Finnish Android links to the live listing; the remaining badges have no download URL and display their current review/development status.
4. **Features and routine:** explain pictures, pronunciation, examples, automatic study, progress, reminders and Finnish offline media.
5. **Offer:** Finnish free/Premium details and a link back to the language download cards.
6. **FAQs and footer:** release states, separate apps/platform purchases, exam scope, offline use and local progress. Existing Finnish support/privacy pages are retained.

`?language=sv` links directly to the Swedish preview. YKI 3000 is the website umbrella; native names remain 3000 Finnish Words and 3000 Swedish Words.

## Release status — 30 October 2026

- Finnish Android is live: https://play.google.com/store/apps/details?id=com.linapps.ykiflashcards&hl=en . Verified in the browser with an Install action.
- Finnish iOS is being reviewed, per the owner's update. Add its verified App Store link after approval.
- Both Swedish apps are in progress. The collection is growing toward 3,000 words and linguistic review remains pending. Do not advertise a finished collection, launch date or final pricing.
- Finnish basic cards cover all 3,000 pairs; the A set contains 211 complete free lessons. Optional one-time Premium; store supplies regional pricing. Purchases and progress are separate across apps/platforms.
- No official YKI affiliation, exam result guarantee, invented ratings or adoption figures.

## Screenshot provenance

Website JPEGs are resized copies of existing app screenshots; original files are unchanged:

- `finnish-android-{study,words,progress,reminders}.jpg`: `Android/release-preparation/store-listing/en-US/phone-screenshots/`, files 02, 05, 06, 07.
- `finnish-ios-lesson.jpg`: `CommercialValidation/Screenshots/commercial-free-complete-lesson.png`.
- `swedish-ios-study.jpg`: `Swedish3000Native/Verification/iPhone-study.png`.

Phone frames and presentation labels are webpage elements. Screenshots are not regenerated or fabricated. The Swedish screenshot is clearly labelled a development preview.

## Deployment and validation

Published and verified on 30 October 2026. All 12 public content files match the local update byte-for-byte over HTTPS; HTTP redirects correctly. Live browser checks passed for the Google Play link, four app statuses, carousel navigation and the Swedish development preview. Local mobile checks passed at 390 CSS pixels with no horizontal overflow and a working menu. The temporary server archive was moved to recoverable Trash. Evidence: `build/yki3000-showcase-verification.json` and `build/yki3000-carousel-live.png`.

Publish only `index.html`, `style.css`, `app.js`, `privacy.html`, `support.html`, `.htaccess`, `assets/favicon.svg` and the six screenshot JPEGs named above. App sources, account screenshots, credentials and this README do not go in the public package. Retained older public lesson images/audio are harmless but no longer referenced.

`build/yki3000-before-showcase.zip` preserves the previous deployment package. `build/yki3000-showcase-20261030.zip` contains the new public files at its root. Use the confirmed existing document root. Preserve unrelated files and the existing HTTPS configuration. Move the temporary archive to recoverable Trash after extraction.

Check local anchors, asset files, JavaScript syntax, desktop/mobile layouts, carousel arrows/dots/keyboard, language-specific status and CTA changes, and all four cards. After publication verify public file hashes over HTTPS, HTTP redirect, both language options and the Google Play link.

For local preview, from the repository root:

```sh
python3 -m http.server 8040 --bind 127.0.0.1 --directory Website/yki3000
```

## Two-edition redesign

The English page now presents two language editions rather than four platform cards. Each edition has two unmodified official store badges. Asset sources:

- Google: https://play.google.com/intl/en_us/badges/static/images/badges/en_badge_web_generic.png
- Apple: https://developer.apple.com/assets/elements/badges/download-on-the-app-store.svg

The Google PNG contains transparent padding; CSS sizes its visible badge to match the Apple badge without cropping or redrawing either asset. App Store appears first. Unreleased badges are non-interactive with `aria-disabled` and explicit status labels. Only Finnish Google Play has a download URL.

Update package: `build/yki3000-two-editions.zip`, containing only the three changed website files and two new badge assets. Prior source remains in `build/yki3000-showcase-20261030.zip`.

Published the two-edition redesign on 30 October 2026. All five changed files match the source over public HTTPS. Live browser verification confirms two panels, four loaded official badge images, the correct Finnish Google Play link, and three non-interactive badges for unreleased versions. The temporary upload archive was moved to recoverable Trash. Evidence: `build/yki3000-two-editions-verification.json` and `build/yki3000-two-editions-live.png`.

## Pricing page and homepage section

Published at https://yki.essaykingapp.com/pricing.html with a homepage section at `#pricing` (legacy `#get-app` still points there). The menu and footer link to Pricing. Navigation behavior is shared in `navigation.js`.

Verified live in Google Play Console on 30 October 2026: Complete Finnish lessons, product `complete`, purchase option `buy`, active, Finland final price EUR 11.99. The price is presented as a one-time Finnish Android in-app purchase, with no monthly fees/subscription and no claim to include other apps or platforms. Local prices are displayed by Google Play inside the app. No future-update or lifetime-service guarantee is advertised.

The page promotes all 3,000 complete illustrated flashcards, images, word/sentence audio, examples, English translations and automatic study. It explains the 211 free complete A-set lessons, includes a feature comparison and purchase FAQs, and links to the free Google Play download. Payment happens inside the app.

Package: `build/yki3000-pricing.zip` (five public files). Previous files were backed up on the host under `/home3/maixuanl/tmp/yki3000-before-pricing-20261030`. All five content hashes verified over public HTTPS. Local mobile menu and overflow checks passed at 390 CSS pixels, along with local links, anchors and JavaScript syntax. Live navigation and pricing scope passed. Evidence: `build/yki3000-pricing-price-evidence.json`, `build/yki3000-pricing-verification.json`, `build/yki3000-pricing-live.png`.


## Website update — 4 November 2026

Published to the existing Bluehost document root. Owner confirms Swedish Android is publicly available; its download badge now links to `https://play.google.com/store/apps/details?id=com.linapps.swedish3000&hl=en`. Both iOS editions display **Coming soon**. These release details supersede the older status notes above.

Added homepage `#why-3000` and `why-3000.html`, linked in navigation and footer. Copy explains a focused everyday vocabulary goal, its role across all four skills, and support for B1 study and wider YKI preparation. It cites Council of Europe B1 descriptions and avoids claiming that 3,000 words is an official B1 threshold. Slideshow retained; release labels and Swedish feature copy refreshed.

All five changed public files match local source byte-for-byte over HTTPS. JavaScript syntax, desktop/mobile method page layout, language switching, carousel navigation and the new page link were checked. The prior four public files are backed up in `build/yki3000-before-method-20261104.zip`; update package: `build/yki3000-method-20261104.zip`. The temporary hosting archive was moved to recoverable Trash. Verification: `build/yki3000-method-verification.json`; live preview: `build/yki3000-method-live.png`.


## Social sharing thumbnail — 4 November 2026

Added a dedicated 1200 × 630 JPEG at `assets/yki3000-social-20261104.jpg`, composed from editable HTML/CSS and the real Finnish Android study screenshot. Source: `build/yki3000-social-card.html`. Headline: “3,000 words. More confidence.” Both language editions and current platform availability appear in the artwork.

Homepage, pricing and method page now include an absolute HTTPS image URL, MIME type, explicit dimensions, image description, site name and Twitter large-image card metadata. The homepage social title and description were refreshed. All four published files match local source over HTTPS, including requests with Facebook crawler user agent. Backup: `build/yki3000-before-social-20261104.zip`; package: `build/yki3000-social-20261104.zip`; checks: `build/yki3000-social-verification.json`.

Facebook Sharing Debugger was refreshed successfully and visibly renders the new large thumbnail, title and description for the homepage. Evidence: `build/yki3000-facebook-preview.png`. Temporary upload archive moved to recoverable Trash.


## Apple lesson and productive recall update — 4 November 2026

Prepared `build/yki3000-recall-20261104.zip` with seven public files. First carousel item is now the real `fi-0136` apple/omena lesson artwork, labelled as artwork; remaining slides are genuine Android and iOS screenshots. The ambiguous article/cat example is removed from the carousel. New versioned thumbnail: `assets/yki3000-social-20261104-omena.jpg`. Both show the same O + MEN + A(pple) → OMENA memory cue, explicitly separate from pronunciation.

“How it works” now explains English → Finnish/Swedish productive recall, the gap between recognition and production, and a three-step practice routine. `why-3000.html#active-recall` adds context and a primary research citation (Yanagisawa 2016). Claims are scoped to productive retrieval, without asserting a universally best learning direction. Both-direction reading/listening practice remains encouraged.

Owner confirms current store price is €11.99. Public pricing stays €11.99 with a launch-price label; no invented reference-price discount or percentage is published. A separate private, clearly marked styling concept is in `build/yki3000-price-concept.html` and excluded from the deployment archive. Backup: `build/yki3000-before-recall-20261104.zip`.

Local JavaScript syntax, internal references, desktop layout, narrow viewport overflow, carousel navigation and metadata checked. Published after renewed Bluehost sign-in. All seven public files match local source over HTTPS (`build/yki3000-recall-verification.json`). Facebook Sharing Debugger refreshed successfully and visibly displays the apple/omena thumbnail (`build/yki3000-facebook-omena-preview.png`). Live homepage checked after reload (`build/yki3000-omena-homepage-live.png`). Temporary archive moved to recoverable Trash.


## Phone mockup thumbnail — 4 November 2026

Restored a tilted phone mockup in the social thumbnail, showing the unmodified real iOS apple/omena lesson screenshot. A separate stylised English “apple” card with a flip arrow sits behind the phone to convey the flashcard flow. Thumbnail is `assets/yki3000-social-20261104-phone.jpg` (1200 × 630). Updated social image references on home, pricing and method pages; homepage content is otherwise unchanged. Editable artwork source remains `build/yki3000-social-card.html`. Package: `build/yki3000-phone-thumbnail.zip`; backup: `build/yki3000-before-phone-thumbnail.zip`; all four public files matched over HTTPS, with the image also checked using Facebook crawler user agent. Verification: `build/yki3000-phone-thumbnail-verification.json`.


## Passion recall example — 4 November 2026

Published a text-only change to `index.html#routine` and `why-3000.html#active-recall`: passion → intohimo replaces apple → omena as the productive-recall example. The compound cue and example sentence match app entry fi-1891: into = enthusiasm + himo = craving; Intohimo näkyy työssä. Hero imagery, social thumbnail, pricing and app availability remain unchanged. Both public pages match local source over HTTPS; visual layout checked in browser. Evidence: `build/yki3000-passion-verification.json` and `build/yki3000-passion-live.png`. Package: `build/yki3000-passion-example.zip`; backup: `build/yki3000-before-passion-example.zip`. Temporary upload moved to recoverable Trash.


## Approved Why 3,000 release — 4 November 2026

Published the approved frequency diagram and copy on the homepage `#why-3000` and `why-3000.html`. Diagram distinguishes vocabulary count from occurrence frequency; selected English native-vocabulary estimates (17,000–20,000 word families) and the illustrative 90% scenario are explicitly labelled. Added final owner-requested caption: “3,000 core words — a much larger share of everyday use.” Removed the discarded 100-token strip. Explains B1 (YKI level 3), sentence context/audio and mnemonic imagery. Existing passion/intohimo recall section, omena hero, phone social thumbnail, store availability and pricing retained.

Package: `build/yki3000-why-release.zip`; previous three public files backed up in `build/yki3000-before-why-release.zip`. All three deployed files match source over HTTPS (`build/yki3000-why-release-verification.json`). Desktop and phone-width layout checked; no horizontal overflow at 433 CSS pixels. Live screenshot: `build/yki3000-why-release-live.png`. Temporary hosting archive moved to recoverable Trash.


## Finnish YKI social title — 4 November 2026

Homepage Facebook/Open Graph and Twitter title updated to “Master key Finnish vocabulary for the YKI test | YKI 3000”. Social description now focuses on Finnish vocabulary for YKI, illustrated flashcards, pronunciation and sentence context. Phone-mockup image and page body retained. The uploaded homepage matches local source over HTTPS using the Facebook crawler user agent. Backup: `build/yki3000-before-finnish-share-title.html`; package: `build/yki3000-finnish-share-title.zip`.

Social headline revised to “Master key Finnish/Swedish vocabulary for the YKI test | YKI 3000”, with both languages reflected in the description. Public homepage matches source over HTTPS. Backup: `build/yki3000-before-bilingual-share-title.html`.

Removed the visible explanatory paragraph beneath the frequency circles from both homepage and Why 3,000 page, at owner request. Chart labels and surrounding content retained. Both live pages verified byte-for-byte against source. Backups: `build/before-remove-chart-note-index.html` and `build/before-remove-chart-note-why-3000.html`.


### Launch pricing — 4 November 2026
Published the owner-confirmed €24.99 regular price after launch as a struck-through reference alongside the current €11.99 launch price on the homepage and pricing page. The future-price label is visible; current Finland Finnish Android price and store configuration remain €11.99. Verified all three published files against local sources.


## All four apps released — 6 November 2026

Published to the existing Bluehost website. This release status supersedes all earlier review, development and coming-soon notes above. Both language editions are available on iOS and Android.

- Finnish iOS: https://apps.apple.com/app/id6826695314
- Swedish iOS: https://apps.apple.com/app/id6829552895
- Finnish Android: https://play.google.com/store/apps/details?id=com.linapps.ykiflashcards&hl=en
- Swedish Android: https://play.google.com/store/apps/details?id=com.linapps.swedish3000&hl=en

Activated both official Apple badges. Updated homepage metadata, language-switching copy, carousel captions, release FAQs and the pricing FAQ. Swedish copy now reflects the store listings: 3,000 word pairs, prerecorded pronunciation and offline media downloads. The published €11.99/€24.99 launch/reference pricing remains explicitly scoped to Finnish Android in Finland.

Re-rendered the existing HTML/CSS social-card design with “Available on iOS & Android”; new image `assets/yki3000-social-20261106.jpg` is 1200 × 630. Homepage, pricing and method page use the new versioned image URL. Social networks may retain previously cached previews until they refresh.

All five published files match local source byte-for-byte over HTTPS. Live browser checks confirm the four active store links and language switching. JavaScript syntax checked. The browser viewport override did not take effect, so a new phone-width layout check could not be confirmed; desktop layout was visually checked. Package: `build/yki3000-four-stores-20261106.zip`; live backup: `build/yki3000-before-four-stores-live-20261106.zip`; verification: `build/yki3000-four-stores-verification.json`; screenshot: `build/yki3000-four-stores-live.png`.

Temporary server upload archive moved to recoverable Trash after publication.


## Full website and pricing audit

Owner confirmed the same Finland pricing for Finnish iOS, Finnish Android, Swedish iOS and Swedish Android: €11.99 launch price and €24.99 regular price after launch, purchased separately per app and platform. This supersedes the earlier Finnish-Android-only pricing scope.

Published two language pricing panels with both platform prices and four official store badges on both home and Pricing. Generalised the Free/Premium comparison, purchase/restore instructions, pricing FAQ and metadata to all four apps. Clarified local prices and separate purchases.

Audited eight HTML pages, internal links, assets, anchors and accessibility targets. Fixed the separate Swedish introduction still saying iOS was being prepared for release; added store links and pricing navigation to the Swedish pages. Corrected Finnish support instructions to cover Android and iOS and corrected the website hosting description in the Finnish privacy page.

JavaScript syntax passed. Browser checks passed for the desktop price panels, Swedish homepage selection, phone-width layouts (433 CSS pixels with no horizontal overflow), and the mobile navigation menu. All ten public files match local source byte-for-byte over HTTPS. Existing social artwork and store prices were not changed.

Package: `build/yki3000-pricing-audit.zip`; prior public files: `build/yki3000-before-pricing-audit.zip`; validation: `build/yki3000-pricing-audit-checks.json` and `build/yki3000-pricing-audit-verification.json`; screenshots: `build/yki3000-pricing-audit-live.png` and `build/yki3000-pricing-audit-mobile.png`. Temporary upload archive moved to recoverable Trash.
