"""Create captioned App Store previews and animated Google Play promos."""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont, ImageOps
import subprocess, json
ROOT=Path(__file__).resolve().parents[2]
OUT=Path(__file__).resolve().parent
FF='/private/tmp/janna-video-env/bin/ffmpeg'
FONT='/System/Library/Fonts/Avenir Next.ttc'
def run(args):
    subprocess.run([FF,'-y','-loglevel','error',*map(str,args)],check=True)

for lang in ['finnish','swedish']:
    target=OUT/lang/'video';target.mkdir(parents=True,exist_ok=True)
    # This is genuine screen-recorded app footage, with no device frame.
    if lang=='finnish':
        src=ROOT/'CommercialValidation/phone-retry-attachments/441AFC7E-105C-42E0-9FAA-7865C49C5186.mp4'
        start,duration=35,17
        captions=[('Make every Finnish word memorable',0,6),('A little recall. A lasting memory.',6,8),('Find a word. Make it yours.',8,17)]
    else:
        src=ROOT/'Swedish3000Native/Verification/ReleasePreparation/Swedish3000-iPhone-review.mp4'
        start,duration=7,22
        captions=[('Make every Swedish word memorable',0,7),('Examples that bring words to life',7,14),('Read it. Hear it. Remember it.',14,22)]
    overlays=[]
    for i,(text,a,b) in enumerate(captions):
        im=Image.new('RGBA',(886,1920));d=ImageDraw.Draw(im)
        d.rounded_rectangle((24,1650,862,1742),radius=20,fill=(16,40,36,245) if lang=='finnish' else (16,53,83,245))
        f=ImageFont.truetype(FONT,34)
        d.text((443,1696),text,font=f,fill='white',anchor='mm')
        p=target/f'caption-{i}.png';im.save(p);overlays.append((p,a,b))
    args=['-i',src,'-f','lavfi','-i','anullsrc=channel_layout=stereo:sample_rate=48000']
    for p,_,_ in overlays: args+=['-loop','1','-i',p]
    if lang=='finnish':
        filt='[0:v]split=4[a][b][c][d];[a]trim=start=42:end=44,setpts=3*(PTS-STARTPTS)[a1];[b]trim=start=35:end=37,setpts=PTS-STARTPTS[b1];[c]trim=start=37:end=41,setpts=PTS-STARTPTS[c1];[d]trim=start=44:end=49,setpts=PTS-STARTPTS[d1];[a1][b1][c1][d1]concat=n=4:v=1:a=0,scale=886:1920,fps=30,setsar=1,format=yuv420p[v0];'
    else:
        filt=f'[0:v]trim=start={start}:end={start+duration},setpts=PTS-STARTPTS,scale=886:1920,fps=30,setsar=1,format=yuv420p[v0];'
    for i,(_,a,b) in enumerate(overlays):filt+=f"[v{i}][{i+2}:v]overlay=0:0:enable='between(t,{a},{b})'[v{i+1}];"
    args+=['-filter_complex',filt.rstrip(';'),'-map',f'[v{len(overlays)}]','-map','1:a','-t',duration,'-c:v','libx264','-profile:v','high','-level:v','4.0','-preset','fast','-b:v','10M','-maxrate','12M','-bufsize','20M','-pix_fmt','yuv420p','-c:a','aac','-b:a','256k','-ac','2','-movflags','+faststart',target/'app-store-preview.mp4']
    run(args)
    # Google Play promo uses only Android screenshots, animated over the matching brand layout.
    screens=sorted((OUT/lang/'android').glob('*.png'))
    clips=[]
    for i,p in enumerate(screens):
        im=Image.open(p).convert('RGB');im=ImageOps.contain(im,(608,1080))
        canvas=Image.new('RGB',(1920,1080),'#123F35' if lang=='finnish' else '#103C61')
        canvas.paste(im,(1170,0));d=ImageDraw.Draw(canvas)
        d.text((125,170),'3000',font=ImageFont.truetype('/System/Library/Fonts/Supplemental/Georgia Bold.ttf',140),fill='#F5F2E9')
        d.text((130,345),lang.upper()+' WORDS',font=ImageFont.truetype(FONT,55),fill='#D7E4D2')
        texts=[('Picture it.', 'Illustrated flashcards that stick.'),('Hear it.', 'Build recall at your own pace.'),('Keep growing.', 'See the words you know.'),('Make time for words.', 'Learn a little, every day.'),('Remember it.', 'Your next word starts here.')]
        title,subtitle=texts[i]
        d.text((130,560),title,font=ImageFont.truetype('/System/Library/Fonts/Supplemental/Georgia Bold.ttf',65),fill='#F5F2E9')
        d.text((130,670),subtitle,font=ImageFont.truetype(FONT,38),fill='#F5F2E9')
        d.text((130,900),'Try the free lessons.',font=ImageFont.truetype(FONT,34),fill='#D7E4D2')
        frame=target/f'promo-scene-{i}.png';canvas.save(frame)
        clip=target/f'scene-{i}.mp4';clips.append(clip)
        run(['-loop','1','-i',frame,'-f','lavfi','-i','anullsrc=channel_layout=stereo:sample_rate=48000','-vf',"scale=1958:1102,crop=1920:1080:x='19+12*sin(t/3)':y=11,fade=t=in:st=0:d=0.25,fade=t=out:st=4.75:d=0.25",'-t','5','-r','30','-c:v','libx264','-preset','fast','-crf','19','-pix_fmt','yuv420p','-c:a','aac','-b:a','256k','-shortest',clip])
    concat=target/'concat.txt';concat.write_text('\n'.join("file '"+p.name+"'" for p in clips))
    run(['-f','concat','-safe','0','-i',concat,'-c','copy','-movflags','+faststart',target/'google-play-promo.mp4'])
    for p in clips:p.unlink()
    print(f'Created {lang} App Store preview and Google Play promo.',flush=True)
