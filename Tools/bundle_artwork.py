#!/usr/bin/env python3
"""Copy approved letter artwork into the iOS resources without original PNGs or base64."""
import argparse
import hashlib
import json
from pathlib import Path
import shutil
import sqlite3

APP = Path(__file__).resolve().parents[1]
LIBRARY = APP.parent / 'SisuArtwork'
DESTINATION = APP / 'Resources/BundledArtwork'


def main():
    parser=argparse.ArgumentParser();parser.add_argument('--letters',nargs='+',default=list('ABCDEFGHIJKLMNOPQRSTUVWYZ'));args=parser.parse_args()
    selected=[];expected=set()
    entries=json.loads((APP / 'Resources/catalog3000.json').read_text())['entries']
    for letter in args.letters:
        records=json.loads((LIBRARY / f'letters/{letter}/Artwork-catalog.json').read_text())
        letter_ids={x['id'] for x in entries if x['english'].lower().startswith(letter.lower())}
        assert len(records)==len(letter_ids) and all(x['reviewStatus']=='approved' for x in records), letter
        assert {x['wordID'] for x in records}==letter_ids, letter
        selected.extend(records);expected.update(letter_ids)
    assert len(selected)==len(expected)
    DESTINATION.mkdir(parents=True, exist_ok=True)
    c = sqlite3.connect(LIBRARY / 'artwork.sqlite')
    c.row_factory = sqlite3.Row
    records = []
    for item in selected:
        a = c.execute('SELECT * FROM assets WHERE asset_id=?', (item['assetID'],)).fetchone()
        assert a and a['review_status'] == 'approved' and a['word_id'] == item['wordID']
        full = LIBRARY / a['full_path']
        assert hashlib.sha256(full.read_bytes()).hexdigest() == a['full_sha256']
        thumb = LIBRARY / a['thumbnail_path']
        for source in [full, thumb]:
            shutil.copy2(source, DESTINATION / source.name)
        records.append(dict(wordID=a['word_id'], assetID=a['asset_id'], filename=full.name,
                            thumbnailFilename=thumb.name, memoryHook=a['mnemonic'], prompt=a['prompt']))
    c.close()
    (DESTINATION / 'manifest.json').write_text(json.dumps(records, ensure_ascii=False, indent=2) + '\n')
    print(json.dumps(dict(bundledImages=len(records), resourceBytes=sum(p.stat().st_size for p in DESTINATION.iterdir())), indent=2))


if __name__ == '__main__':
    main()
