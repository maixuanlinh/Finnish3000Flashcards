#!/usr/bin/env python3
"""Verify reused source assets without modifying or decoding/recompressing images."""
import hashlib
import json
from pathlib import Path
import zipfile

root = Path(__file__).resolve().parents[2]
resources = root / 'Resources'
catalog = json.loads((resources / 'catalog3000.json').read_text())['entries']
examples = json.loads((resources / 'examples3000.json').read_text())
art = json.loads((resources / 'BundledArtwork/manifest.json').read_text())
starter = json.loads((resources / 'starter100.json').read_text())
ids = {w['id'] for w in catalog}
assert len(catalog) == len(ids) == len(examples) == len(art) == 3000
assert {e['id'] for e in examples} == {a['wordID'] for a in art} == ids
assert len({e['id'] for e in examples}) == len(examples)
assert len({e['wordID'] for e in art}) == len(art)
assert {w['id'] for w in starter} <= ids
assert all(e['sentence'].strip() and e['sentenceEnglish'].strip() for e in examples)
assert sum(w['english'].lower().startswith('a') for w in catalog) == 211
for row in art:
    for key in ('filename', 'thumbnailFilename'):
        path = resources / 'BundledArtwork' / row[key]
        assert path.parent == resources / 'BundledArtwork'
        assert path.is_file() and path.stat().st_size > 0, path
print('PASS: 3,000 stable IDs, bilingual examples, artwork pairs; 211 free A lessons.')
apk = root / 'Android/app/build/outputs/apk/debug/app-debug.apk'
if apk.exists():
    with zipfile.ZipFile(apk) as archive:
        metadata = [resources / name for name in ('catalog3000.json', 'starter100.json', 'examples3000.json', 'artworkBriefs.json')] + [resources / 'BundledArtwork/manifest.json']
        paths = metadata if 'assets/lesson-media.json' in archive.namelist() else metadata + list((resources / 'BundledArtwork').glob('*.jpg'))
        for path in paths:
            if path.is_file():
                target = 'assets/' + str(path.relative_to(resources))
                assert hashlib.sha256(path.read_bytes()).digest() == hashlib.sha256(archive.read(target)).digest(), target
        if 'assets/lesson-media.json' in archive.namelist():
            manifest = json.loads(archive.read('assets/lesson-media.json'))
            assert manifest['wordCount'] == 3000 and manifest['recordingCount'] == 8811
            keys = {r['key'] for r in manifest['assets']}
            for row in art:
                assert all('image/' + row[name] in keys for name in ('filename', 'thumbnailFilename'))
            for pack in manifest['packs']:
                target = 'assets/' + pack['file']
                if target in archive.namelist():
                    data = archive.read(target)
                    assert len(data) == pack['bytes'] and hashlib.sha256(data).hexdigest() == pack['sha256']
                else:
                    assert not pack['starter'], 'A starter pack is missing from the installation.'
            print('PASS: media manifest contains every illustration and 8,811 recordings; all bundled pack hashes match.')
    print('PASS: packaged vocabulary/metadata matches iOS source SHA-256.')
else:
    print('APK asset-hash verification pending: compile :app:assembleDebug first.')
