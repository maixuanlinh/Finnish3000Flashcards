# Prerecorded lesson media

The Android update plays prerecorded Finnish words, English words and Finnish examples. It does not call Android TextToSpeech or require phone voice installation. Vocabulary, ratings, purchase access and personal artwork retain their original IDs and storage.

## Build the collection without a paid API

Use Python 3.12 or later in a local environment with `Tools/media/requirements.txt`. Download the following voices from the publisher's `rhasspy/piper-voices` repository on Hugging Face, including the matching `.onnx.json` files:

- `fi/fi_FI/harri/medium/fi_FI-harri-medium.onnx`
- `en/en_US/ljspeech/high/en_US-ljspeech-high.onnx`

The publisher identifies Harri's Finnish training dataset as CC0 and LJ Speech as public domain. See [audio provenance](NOTICE.md). Models and the speech engine are development tools, not files distributed to phones or uploaded to Bluehost.

Run `Tools/media/build_lesson_media.py --models PATH_TO_MODELS`. It reads the canonical Resources without modifying them, generates 8,811 distinct recordings for 9,000 playback positions, converts images to WebP at quality 85, and creates content-addressed packs of at most 8 MB. Runs can resume from verified audio and image outputs. The generator records exact model hashes and synthesis parameters in its manifest.

- `work/`: intermediate recordings, optimized images and resumable generation index.
- `public/v1/`: publish only this directory's contents to the hosted media directory.
- `generated/assets/`: immutable manifest plus the starter packs for the app.
- `size-report.json`: actual byte counts, including the starter content.

The immutable `generated/assets/` manifest and starter packs are tracked in Git so a fresh checkout can build both native apps. The full `public/` collection and intermediate `work/` directory remain ignored; preserve the complete hosted collection separately. No hosting login, API key or developer speech model belongs in the public directory.

Measured release: **442.3 MB** of media (**317.5 MB** images, **124.8 MB** audio), in **60 packs**. Starter media totals **13.5 MB**. The debug starter installation is approximately **30 MB**; a complete offline debug installation is approximately **459 MB**. Use `Tools/media/verify_lesson_media.py` to independently audit the release. Three small sample recordings are in `samples/`.

## Android builds

Ordinary Android Studio, debug and Play builds use the verified Bluehost directory by default and include only starter media. All canonical text remains bundled. Use `-PmediaBaseUrl=https://HOST/finnish3000/v1` to override the server, or an explicit empty `-PmediaBaseUrl=` for a complete offline development installation. The media URL has no credentials and must use HTTPS.

Progress → Download for offline study and Playback settings → Download for offline study open the same storage controls. Downloads are optional; users can load media online, download over an unmetered connection, pause/resume, and remove downloaded packs. Full downloads are saved in app files rather than the Android cache. Online media uses a bounded 64 MB cache.

The downloader checks sizes and SHA-256, supports byte-range requests and interrupted-pack resumption, and falls back to a bounded full-pack response when a host ignores ranges. A completed partial file can be committed after process death without downloading again. One short background job handles each pack. Pending work survives normal app/process restarts through WorkManager. Removing media never removes learning records or personal artwork. Phone notifications use only locally available thumbnails and never initiate a media download.

## Bluehost deployment

Use the existing Essay King website's document root confirmed in cPanel. Put files in a new `finnish3000/v1` directory; do not overwrite WordPress files, modify the subscription, create a new domain, or publish credentials. Upload packs before publishing the manifest. The generated pack count is small, avoiding thousands of new server files.

After upload, verify HTTPS, exact full-pack hashes, a 206 response with the correct Content-Range for one asset, and actual Android playback before preparing a Play update. The existing prepaid subscription and unmetered transfer remain subject to Bluehost's account/resource policies; deployment does not constitute a guarantee against future hosting charges. The account assessment is kept locally under Android/release-preparation.

Deployed and verified on 28 October 2026. The live phone installation page is **https://essaykingapp.com/finnish3000/install/**; the app uses **https://essaykingapp.com/finnish3000/v1**. Archives were extracted in the confirmed Essay King document root and created only the new `finnish3000/v1/` and `finnish3000/install/` directories. They contain no WordPress root files, speech models or credentials. Temporary server upload archives were moved to recoverable Trash.

The 30,002,362-byte preview APK is preserved at `build/media-release/finnish-words-preview.apk`. Build with `-PphonePreview=true -PmediaBaseUrl=https://essaykingapp.com/finnish3000/v1` to use the separate `.preview` package and label, protecting the production app's progress. No Play release was published. Preview progress and purchase access are separate from the Play app.

Verification passed: exact manifest, all 60 pack lengths, three asset ranges with SHA-256 (image/Finnish/English), one full non-starter pack SHA-256, APK MIME type and full APK SHA-256. Recheck with `Tools/media/verify_hosted_media.py`; generated evidence is in `build/media-release/hosting-verification.json`. The preview passed two API 34 emulator checks, including actual non-starter media retrieval and RecordedSpeech playback from Bluehost, automatic apple playback and offline storage controls. Current unit-test count is 41 with zero failures.

Audio is synthetic. Automated duration/format checks establish file integrity, not perfect native pronunciation. Representative Finnish pronunciation and English clips should receive human listening review before a production release.
