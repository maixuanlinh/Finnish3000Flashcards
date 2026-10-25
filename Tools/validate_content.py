#!/usr/bin/env python3
"""Check full word/example coverage and data integrity; optionally save a JSON report."""
import argparse
from collections import Counter
import json
from pathlib import Path
import re


def validate(root):
    catalog = json.loads((root / 'catalog3000.json').read_text())
    starter = json.loads((root / 'starter100.json').read_text())
    examples = json.loads((root / 'examples3000.json').read_text())
    entries = catalog['entries']
    assert len(entries) == catalog['entryCount'] == 3000
    ids = {entry['id'] for entry in entries}
    assert len(ids) == 3000
    assert {entry['sourceID'] for entry in entries} == set(range(1, 3001))
    assert all(entry['id'] == f"fi-{entry['sourceID']:04d}" for entry in entries)
    assert all(entry['english'].strip() and entry['finnish'].strip() for entry in entries)
    assert len(examples) == 3000 and {entry['id'] for entry in examples} == ids
    assert len(starter) == len({entry['id'] for entry in starter}) == 100
    assert {entry['id'] for entry in starter} <= ids
    assert {entry['order'] for entry in starter} == set(range(100))
    assert all(entry['sentence'].strip() and entry['sentence'][-1] in '.!?' for entry in examples)
    assert all(not re.search(r'\b(\w+)\s+\1\b', entry['sentence'], re.I) for entry in examples)
    assert all('~' not in entry['sentence'] and '\n' not in entry['sentence'] for entry in examples)
    assert all(isinstance(entry['sentenceEnglish'], str) and entry['sentenceEnglish'].strip()
               and entry['sentenceEnglish'][-1] in '.!?' for entry in examples)
    assert all('\n' not in entry['sentenceEnglish'] and '\t' not in entry['sentenceEnglish']
               and entry['sentenceEnglish'] != entry['sentence'] for entry in examples)
    by_id = {entry['id']: entry for entry in examples}
    assert all(entry['sentence'] == by_id[entry['id']]['sentence'] and
               entry['sentenceEnglish'] == by_id[entry['id']]['sentenceEnglish'] for entry in starter)
    by_sentence = {}
    for entry in examples:
        previous = by_sentence.setdefault(entry['sentence'], entry['sentenceEnglish'])
        assert previous == entry['sentenceEnglish'], entry['id']
    active_images = [entry['id'] for entry in starter if entry.get('imageName') and
                     (not entry['imageContainsText'] or entry['sentence'] == by_id[entry['id']]['sentence'])]
    artwork_folder = root / 'BundledArtwork'
    artwork = json.loads((artwork_folder / 'manifest.json').read_text())
    expected_artwork_ids = ids
    assert len(artwork) == len(expected_artwork_ids) == 3000
    assert {entry['wordID'] for entry in artwork} == expected_artwork_ids
    assert len({entry['assetID'] for entry in artwork}) == 3000
    for entry in artwork:
        assert entry['memoryHook'] and entry['prompt']
        for key in ['filename', 'thumbnailFilename']:
            assert Path(entry[key]).name == entry[key]
            image = artwork_folder / entry[key]
            assert image.is_file() and image.read_bytes().startswith(b'\xff\xd8')
    return dict(version='0.21.0', cards=len(entries), FinnishExamples=len(examples),
                missingExamples=0, duplicateIDs=0, emptyTranslations=0,
                EnglishSentenceTranslations=len(examples), missingSentenceTranslations=0,
                synchronizedStarterTranslations=len(starter),
                distinctExampleSentences=len(Counter(entry['sentence'] for entry in examples)),
                activeIllustrations=len(set(active_images) | expected_artwork_ids),
                originalCompatibleIllustrations=len(active_images),
                bundledIllustrations=len(artwork),
                bundledArtworkBytes=sum(p.stat().st_size for p in artwork_folder.iterdir() if p.is_file()),
                checks='ID coverage, required Finnish/English sentence text, punctuation, duplicate-sentence consistency, starter synchronization, and artwork resource consistency',
                note='English translations were authored from each actual Finnish sentence. Structural checks do not constitute independent linguistic review.')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--report', type=Path)
    args = parser.parse_args()
    report = validate(Path(__file__).resolve().parents[1] / 'Resources')
    if args.report:
        args.report.write_text(json.dumps(report, ensure_ascii=False, indent=2) + '\n')
    print(json.dumps(report, ensure_ascii=False, indent=2))


if __name__ == '__main__':
    main()
