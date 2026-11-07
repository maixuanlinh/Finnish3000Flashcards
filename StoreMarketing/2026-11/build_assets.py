"""Rebuild store artwork from genuine, unmodified app captures."""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont, ImageFilter, ImageOps
import json

ROOT = Path(__file__).resolve().parents[2]
OUT = Path(__file__).resolve().parent
FONT = '/System/Library/Fonts/Avenir Next.ttc'
SERIF = '/System/Library/Fonts/Supplemental/Georgia Bold.ttf'

def font(n, serif=False):
    return ImageFont.truetype(SERIF if serif else FONT, int(n))

def centered(d, text, y, size, color, w, serif=False):
    f = font(size, serif)
    assert d.textlength(text, font=f) <= w-70, text
    d.text((w/2,y), text, font=f, fill=color, anchor='mt')

def render(src, target, lang, headline, sub, number, size):
    w,h=size; k=w/1320
    dark = '#123F35' if lang=='Finnish' else '#103C61'
    accent = '#B9D3A6' if lang=='Finnish' else '#AECFE8'
    bg=Image.new('RGB', size, '#F5F2E9'); d=ImageDraw.Draw(bg)
    d.ellipse((int(-w*.6),int(h*.44),int(w*1.6),int(h*1.3)),fill=dark)
    d.arc((int(-w*.16),int(h*.38),int(w*1.18),int(h*.99)),195,330,fill=accent,width=max(1,int(2*k)))
    centered(d, f'3000 {lang.upper()} WORDS', 105*k, 29*k,dark,w)
    for i,line in enumerate(headline.split('\n')):
        centered(d,line,(205+i*108)*k,86*k,dark,w,True)
    sy=(225+len(headline.split('\n'))*108)*k
    for i,line in enumerate(sub.split('\n')):
        centered(d,line,sy+i*47*k,34*k,dark,w)
    im=Image.open(src).convert('RGB')
    top=int(max(sy+130*k,h*.267)); bottom=int(h*.933)
    scale=min((w*.83)/im.width,(bottom-top)/im.height)
    sw,sh=int(im.width*scale),int(im.height*scale)
    x=(w-sw)//2;y=top; border=max(6,int(13*k));r=int(55*k)
    shadow=Image.new('RGBA',size);sd=ImageDraw.Draw(shadow)
    sd.rounded_rectangle((x-border,y-border+22*k,x+sw+border,y+sh+border+22*k),r,fill=(0,0,0,90))
    bg=Image.alpha_composite(bg.convert('RGBA'),shadow.filter(ImageFilter.GaussianBlur(28*k)))
    d=ImageDraw.Draw(bg);d.rounded_rectangle((x-border,y-border,x+sw+border,y+sh+border),r,fill='#1B2428',outline='#69736E',width=max(1,int(2*k)))
    screen=im.resize((sw,sh),Image.Resampling.LANCZOS);mask=Image.new('L',(sw,sh));ImageDraw.Draw(mask).rounded_rectangle((0,0,sw,sh),max(8,r-border),fill=255)
    bg.paste(screen,(x,y),mask)
    d=ImageDraw.Draw(bg)
    centered(d,'PICTURE IT.  HEAR IT.  REMEMBER IT.',h-105*k,24*k,'#F6F2E8',w)
    for j in range(5):
        cx=w//2+(j-2)*27*k;cy=h-42*k
        d.ellipse((cx-4*k,cy-4*k,cx+4*k,cy+4*k),fill=accent if j==number else '#618078')
    target.parent.mkdir(parents=True,exist_ok=True);bg.convert('RGB').save(target)

fi_phone=ROOT/'CommercialValidation/build30-iphone-screenshots'
fi_pad=ROOT/'CommercialValidation/build30-ipad-screenshots'
sv=ROOT/'Swedish3000Native/Verification/ReleasePreparation/Screenshots'
fi_files=['D04B885B-9668-4F05-AF03-954BE342C563.png','DD89933A-2041-41E2-9365-2B91315D4270.png','DBB6CAC5-72D3-42B0-94EB-458433341681.png','B9CAE061-AF60-47A4-A850-C3AE08EB7DF4.png','6CE3B7E0-4837-4B07-9828-14587705F5F7.png']
fi_pad_files=['4B70197C-5BAC-4628-B6FE-C59B2040D197.png','FF9BE5EB-6DFB-4F1D-A340-922F9F470209.png','5F0E0664-A8C8-4935-81E5-60A1AFEB1C3F.png','DB2DE171-1893-455A-AEE6-EBB9302741EF.png','D8AE99AD-37B0-4B63-A6F5-D650C5A1BC5E.png']
sv_files=['01-illustrated-study.png','03-example-and-audio.png','02-word-library.png','04-learning-progress.png','05-offline-study.png']
fi_android=ROOT/'Android/docs/parity-build29-screenshots/samsung/parity-build29'
sv_android=ROOT/'Swedish3000Native/Verification/Android/screenshots'
manifest=[]
for lang in ['Finnish','Swedish']:
    copy=[('Make every\nword memorable.',f'Illustrated {lang} flashcards.\nA picture for every lesson.'),('Read it.\nHear it. Say it.',f'{lang} examples and translations.\nRecorded pronunciation, ready to play.'),('Find your\nnext word.',f'Explore 3,000 {lang} words.\nSearch, browse, and practise.'),('Small steps.\nVisible progress.','Keep track of the words you know.\nReturn to the ones you’re learning.'),('Take your words\nwith you.','Download lesson media for offline study.\nKeep learning without a connection.')]
    for device,size in [('iphone',(1320,2868)),('iphone-medium',(1206,2622)),('ipad',(2064,2752)),('android',(1080,1920))]:
        if lang=='Finnish':
            sources=[fi_pad/p for p in fi_pad_files] if device=='ipad' else [fi_phone/p for p in fi_files]
            if device=='android': sources=[fi_android/p for p in ['02-study-answer.png','03-word-detail.png','05-library-search.png','06-progress.png','10-playback-complete.png']]
        else:
            sources=[sv/('iPad' if device=='ipad' else 'iPhone')/p for p in sv_files]
            if device=='android':sources=[sv_android/p for p in ['02-study-answer.png','01-study-prompt.png','03-progress.png','04-offline-options.png']]
        indices=[0,1,3,4] if lang=='Swedish' and device=='android' else list(range(5))
        for n,(source,i) in enumerate(zip(sources,indices)):
            headline,sub=copy[i]
            if lang=='Finnish' and device!='android' and i==1:
                headline,sub='A little recall.\nA lasting memory.','Flip each card to reveal the answer.\nMark what you know as you go.'
            if device=='android' and lang=='Swedish' and i==1:
                headline,sub='A little recall.\nA lasting memory.','Flip each card to reveal the answer.\nMark what you know as you go.'
            if device=='android' and lang=='Finnish' and i==4:
                headline,sub='Set your study\nin motion.','Automatic playback for your flashcards.\nLearn at a pace that suits you.'
            target=OUT/lang.lower()/device/f'{n+1:02d}.png'
            render(source,target,lang,headline,sub,n,size)
            manifest.append({'file':str(target.relative_to(OUT)),'source':str(source.relative_to(ROOT)),'headline':headline,'subtitle':sub,'dimensions':size})
    # Play feature graphic, with a real Android app screen.
    dark='#123F35' if lang=='Finnish' else '#103C61'
    graphic=Image.new('RGB',(1024,500),'#F5F2E9');d=ImageDraw.Draw(graphic)
    d.ellipse((550,-200,1250,650),fill=dark)
    d.text((54,65),'3000',font=font(110,True),fill=dark)
    d.text((58,193),f'{lang.upper()} WORDS',font=font(32),fill=dark)
    d.text((58,275),'Picture it. Hear it.',font=font(34,True),fill=dark)
    d.text((58,324),'Remember it.',font=font(34,True),fill=dark)
    src=fi_android/'02-study-answer.png' if lang=='Finnish' else sv_android/'02-study-answer.png'
    im=Image.open(src).convert('RGB');im.thumbnail((240,438))
    x=735-im.width//2;d.rounded_rectangle((x-8,24,x+im.width+8,40+im.height),radius=24,fill='#1B2428')
    graphic.paste(im,(x,32));graphic.save(OUT/lang.lower()/'feature-graphic.png')

(OUT/'manifest.json').write_text(json.dumps(manifest,indent=2,ensure_ascii=False))
thumbs=[]
for lang in ['finnish','swedish']:
    for device in ['iphone','android']:
        for p in sorted((OUT/lang/device).glob('*.png')):
            im=Image.open(p);im=ImageOps.contain(im,(216,470));thumbs.append(im)
sheet=Image.new('RGB',(216*10,490*2),'#e4e0d7')
for i,im in enumerate(thumbs): sheet.paste(im,((i%10)*216,(i//10)*490))
sheet.save(OUT/'collection-preview.jpg',quality=92)
print(f'Generated {len(manifest)} screenshot mockups and 2 feature graphics.')
