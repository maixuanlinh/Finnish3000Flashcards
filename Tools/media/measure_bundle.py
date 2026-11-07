"""Measure a deterministic, length-stratified sample before choosing delivery sizes."""
import io, json, statistics, subprocess, time, wave
from pathlib import Path
from PIL import Image
from piper import SynthesisConfig
import sys
sys.path.insert(0,str(Path(__file__).resolve().parent))
from build_lesson_media import load_words, voice_runtime
import imageio_ffmpeg
import onnxruntime as ort
ort.disable_telemetry_events()

ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'build/media-work/sizing';OUT.mkdir(parents=True,exist_ok=True)
rows=[]
for word in load_words():
    rows.extend([{'text':word['finnish'],'kind':'word-fi'}, {'text':word['english'],'kind':'word-en'}, {'text':word['sentence'],'kind':'sentence-fi'}])
models=ROOT/'build/media-work/models'
ffmpeg=imageio_ffmpeg.get_ffmpeg_exe()
voices, short_directory=voice_runtime(models)
result={'audio':{},'images':{}}
for kind,model in [('word-fi','fi_FI-harri-medium'),('sentence-fi','fi_FI-harri-medium'),('word-en','en_US-ljspeech-high')]:
    group=sorted([r for r in rows if r['kind']==kind],key=lambda r:len(r['text']))
    sample=[group[round((i+.5)*len(group)/12)] for i in range(12)]
    voice=voices['en-US' if kind=='word-en' else 'fi-FI']
    measurements=[]
    for i,row in enumerate(sample):
        filename=OUT/(kind+'-'+str(i))
        wav=filename.with_suffix('.wav');mp3=filename.with_suffix('.mp3')
        if not wav.exists() or wav.stat().st_size<=44:
            with wave.open(str(wav),'wb') as f:
                voice.synthesize_wav(row['text'],f,syn_config=SynthesisConfig(length_scale=1.05))
        with wave.open(str(wav),'rb') as f: seconds=f.getnframes()/f.getframerate()
        if not mp3.exists():
            subprocess.run([ffmpeg,'-v','error','-y','-i',str(wav),'-ac','1','-ar','22050','-codec:a','libmp3lame','-b:a','64k','-map_metadata','-1',str(mp3)],check=True)
        measurements.append({'text':row['text'],'characters':len(row['text']),'seconds':round(seconds,3),'bytes':mp3.stat().st_size})
        print(kind,i+1,len(sample),row['text'],round(seconds,2),mp3.stat().st_size,flush=True)
    avg=statistics.mean(r['bytes'] for r in measurements)
    result['audio'][kind]={'sample':measurements,'estimatedBytes':round(avg*len(group)),'estimatedSeconds':round(statistics.mean(r['seconds'] for r in measurements)*len(group))}
    (OUT/'measurements.json').write_text(json.dumps(result,ensure_ascii=False,indent=2))

for kind,files in [('full',sorted(f for f in (ROOT/'Resources/BundledArtwork').glob('*.jpg') if not f.name.endswith('-thumb.jpg'))),('thumbnail',sorted((ROOT/'Resources/BundledArtwork').glob('*-thumb.jpg')))]:
    sample=[files[round((i+.5)*len(files)/30)] for i in range(30)]
    original=encoded=0
    for f in sample:
        with Image.open(f) as im:
            out=io.BytesIO();im.save(out,format='WEBP',quality=85,method=4)
        original+=f.stat().st_size;encoded+=out.tell()
    total=sum(f.stat().st_size for f in files)
    result['images'][kind]={'sampleOriginalBytes':original,'sampleWebpBytes':encoded,'originalTotalBytes':total,'estimatedWebpBytes':round(total*encoded/original)}
    print('IMAGE',kind,result['images'][kind],flush=True)
(OUT/'measurements.json').write_text(json.dumps(result,ensure_ascii=False,indent=2))
audio=sum(v['estimatedBytes'] for v in result['audio'].values())
original=sum(v['originalTotalBytes'] for v in result['images'].values())
webp=sum(v['estimatedWebpBytes'] for v in result['images'].values())
print('TOTAL_ESTIMATE_MB',{'audio':round(audio/1e6,1),'originalImagesPlusAudio':round((original+audio)/1e6,1),'webpImagesPlusAudio':round((webp+audio)/1e6,1)},flush=True)

(short_directory/'espeak-ng-data').unlink()
short_directory.rmdir()
