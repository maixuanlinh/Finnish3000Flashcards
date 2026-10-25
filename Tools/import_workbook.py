#!/usr/bin/env python3
"""Refresh the bundled 3,000-entry catalog from the master XLSX, using Python's standard library."""
import argparse
import json
import zipfile
import xml.etree.ElementTree as ET
from pathlib import Path

NS = {'s': 'http://schemas.openxmlformats.org/spreadsheetml/2006/main'}
FINNISH_EDITS = {
    'fellow': 'kaveri; toveri; samaan ryhmään kuuluva',
    'supermarket': 'supermarketti; ruokakauppa',
    'rate': 'tahti; määrä; taso; hinta; arvioida',
}

def read_rows(path):
    with zipfile.ZipFile(path) as archive:
        shared = []
        if 'xl/sharedStrings.xml' in archive.namelist():
            tree = ET.fromstring(archive.read('xl/sharedStrings.xml'))
            shared = [''.join(n.itertext()) for n in tree]
        book = ET.fromstring(archive.read('xl/workbook.xml'))
        sheet = next(s for s in book.find('s:sheets', NS) if s.attrib['name'] == 'Finnish list')
        relationship = sheet.attrib['{http://schemas.openxmlformats.org/officeDocument/2006/relationships}id']
        rels = ET.fromstring(archive.read('xl/_rels/workbook.xml.rels'))
        target = next(r.attrib['Target'] for r in rels if r.attrib['Id'] == relationship)
        target = target.lstrip('/') if target.startswith('/') else 'xl/' + target
        tree = ET.fromstring(archive.read(target))
        for row in tree.findall('s:sheetData/s:row', NS):
            values = {}
            for cell in row:
                column = ''.join(c for c in cell.attrib['r'] if c.isalpha())
                value = cell.find('s:v', NS)
                raw = value.text if value is not None else ''
                if cell.attrib.get('t') == 's': raw = shared[int(raw)]
                elif cell.attrib.get('t') == 'inlineStr': raw = ''.join(cell.find('s:is', NS).itertext())
                values[column] = raw or ''
            yield values

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('workbook', type=Path)
    parser.add_argument('--output', type=Path, default=Path(__file__).resolve().parents[1] / 'Resources/catalog3000.json')
    args = parser.parse_args()
    entries = []
    for row in read_rows(args.workbook):
        if not row.get('A', '').isdigit() or not row.get('B') or not row.get('C'): continue
        source_id = int(row['A'])
        entries.append(dict(id=f'fi-{source_id:04d}',sourceID=source_id,
                            english=row['B'],finnish=FINNISH_EDITS.get(row['B'], row['C']),notes=row.get('D', '')))
    if len(entries) != 3000 or len({r['id'] for r in entries}) != 3000:
        raise ValueError(f'Expected 3,000 unique study entries; found {len(entries)}')
    result = dict(source='Oxford-based English-to-Finnish master, version 1',
        sourceURL='https://www.oxfordlearnersdictionaries.com/external/pdf/wordlists/oxford-3000-5000/American_Oxford_3000.pdf',
        entryCount=len(entries),entries=entries)
    args.output.write_text(json.dumps(result,ensure_ascii=False,indent=2),encoding='utf-8')
    print(f'Imported {len(entries)} entries into {args.output}')

if __name__ == '__main__': main()
