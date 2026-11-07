'use strict';
(() => {
  const $ = id => document.getElementById(id);
  let language = 'fi';
  const editions = {
    fi: {
      name:'Finnish', native:'Hei!', word:'omena', sentence:'Omena on punainen.', translation:'The apple is red.',
      image:'assets/finnish-apple.jpg', alt:'Finnish apple lesson: omena, with an illustrated memory trick and the sentence Omena on punainen.',
      description:'Build the vocabulary for everyday life in Finland. Discover 3,000 English–Finnish words through pictures, pronunciation and examples that make them stick.',
      note:'Available now on iOS & Android', count:'3,000', countLabel:'Finnish word pairs',
      intro:'Go beyond a translation. The Finnish app brings together a picture, a voice and a sentence, so every word has something to connect to.',
      audio:'Listen to recordings of Finnish words and example sentences, then take a moment to say them aloud yourself.',
      playback:'Automatic study reveals cards and plays audio at your chosen pace. Adjust recall time and practise with the app open.',
      offline:'Set optional word reminders. Download Finnish pictures and recordings ahead of time to keep studying when you are offline.',
      footnote:'Explore the free lessons, or unlock the complete collection with one purchase.',
      availability:'Finnish is available now on the App Store and Google Play.',
      badge:'THE FINNISH EDITION', offerTitle:'Start with the basics.\nGo further when you’re ready.',
      offer:['Basic cards for all 3,000 word pairs','Word pronunciation, search and reminders','211 complete illustrated A-set lessons free','Optional one-time Premium unlock for all complete lessons and automatic study'],
      offerNote:'No subscription. The store displays the price for your region. iOS and Android purchases are separate.'
    },
    sv: {
      name:'Swedish', native:'Hej!', word:'ett äpple', sentence:'Jag äter ett äpple.', translation:'I am eating an apple.',
      image:'assets/swedish-apple.jpg', alt:'Swedish apple lesson: ett äpple, an illustrated apple and the example Jag äter ett äpple.',
      description:'Make Swedish part of your everyday life. Explore 3,000 English–Swedish word pairs with illustrated lessons, recorded pronunciation and examples. Available now on iOS and Android.',
      note:'Available now on iOS & Android', count:'3,000', countLabel:'Swedish word pairs',
      intro:'Meet the Swedish edition. Illustrated cards, example sentences and familiar study tools bring the vocabulary to life.',
      audio:'Listen to recorded Swedish words and example sentences, then practise saying them aloud yourself.',
      playback:'Automatic study reveals cards and plays recorded audio, with pauses to practise recall at your own pace.',
      offline:'Set optional word reminders. Download Swedish pictures and recordings ahead of time for offline study.',
      footnote:'Both editions include free starter lessons and an optional one-time Premium upgrade.',
      availability:'3000 Swedish Words is available now on the App Store and Google Play.',
      badge:'THE SWEDISH EDITION', offerTitle:'A new language.\nMore words for everyday life.',
      offer:['Illustrated English–Swedish vocabulary','Example sentences with English translations','Study cards, word search and local progress','Available now on the App Store and Google Play'],
      offerNote:'One-time Premium is purchased separately for each language and platform. Your local price appears in the app.'
    }
  };
  const playUrl = 'https://play.google.com/store/apps/details?id=com.linapps.ykiflashcards&hl=en';
  const screenshots = {
    fi: [
      {image:'assets/finnish-omena-memory.jpg',platform:'FINNISH · REAL LESSON ARTWORK',title:'Apple → omena. A picture makes the link.',description:'O + MEN + A(pple) → OMENA: a playful memory cue, paired with the Finnish word and an example. Use the audio for pronunciation.',alt:'Real apple lesson artwork showing men carrying a giant apple and the O plus MEN plus A memory cue for omena.',device:'artwork'},
      {image:'assets/finnish-android-words.jpg',platform:'FINNISH · ANDROID',title:'Find the word you’re looking for.',description:'Search the collection and explore the vocabulary you want to practise.',alt:'Finnish Android vocabulary list and search screen.',device:'android'},
      {image:'assets/finnish-android-progress.jpg',platform:'FINNISH · ANDROID',title:'Watch your vocabulary grow.',description:'Keep track of words you know and build your own daily rhythm.',alt:'Finnish Android progress screen showing known words and word reminders.',device:'android'},
      {image:'assets/finnish-android-reminders.jpg',platform:'FINNISH · ANDROID',title:'A little Finnish, throughout your day.',description:'Set optional word reminders at the times that work for you.',alt:'Finnish Android word reminder settings.',device:'android'},
      {image:'assets/finnish-ios-lesson.jpg',platform:'FINNISH · iOS',title:'Your next chapter, on iPhone too.',description:'The apple lesson inside the iOS app, available now for iPhone and iPad.',alt:'Real Finnish iOS apple lesson screen.',device:'ios'}
    ],
    sv: [
      {image:'assets/swedish-ios-study.jpg',platform:'SWEDISH · iOS',title:'Your Swedish journey starts here.',description:'Illustrated vocabulary and example sentences. Both Swedish apps are available now on the App Store and Google Play.',alt:'Swedish iOS screenshot with an en and ett illustrated lesson and recall controls.',device:'ios'}
    ]
  };
  let slideIndex = 0;
  function showSlide(index) {
    const slides = screenshots[language];
    slideIndex = (index + slides.length) % slides.length;
    const slide = slides[slideIndex];
    $('screenshot-image').src = slide.image;
    $('screenshot-image').alt = slide.alt;
    $('screenshot-device').className = 'screenshot-device ' + slide.device;
    $('screenshot-platform').textContent = slide.platform;
    $('screenshot-title').textContent = slide.title;
    $('screenshot-description').textContent = slide.description;
    document.querySelector('.device-peek').hidden = slides.length < 2;
    $('peek-image').src = slides[(slideIndex + 1) % slides.length].image;
    $('previous-slide').disabled = slides.length < 2;
    $('next-slide').disabled = slides.length < 2;
    $('screenshot-note').textContent = language === 'fi' ? `${slide.device === 'artwork' ? 'Real lesson artwork' : 'Real app screenshot'} · ${slideIndex + 1} / ${slides.length} · Swipe or use the arrows` : 'Real iOS app screenshot · Available now on iOS & Android';
    $('carousel-dots').replaceChildren(...slides.map((item,i) => {
      const button=document.createElement('button');
      button.setAttribute('aria-label',`Show screenshot ${i+1}: ${item.title}`);
      button.setAttribute('aria-current',String(i===slideIndex));
      button.classList.toggle('active',i===slideIndex);
      button.addEventListener('click',() => showSlide(i));
      return button;
    }));
  }
  function setLanguage(code, updateUrl = true) {
    if (!editions[code]) return;
    language = code;
    const edition = editions[code];
    const finnish = code === 'fi';
    document.querySelectorAll('.language-button').forEach(button => {
      const active = button.dataset.language === code;
      button.classList.toggle('active',active);
      button.setAttribute('aria-pressed',String(active));
    });
    $('hero-language').textContent = edition.name + '.';
    $('hero-description').textContent = edition.description;
    $('hero-note').textContent = edition.name + ' · Available now on iOS & Android';
    $('hero-cta').textContent = 'Choose your app ↓';
    $('hero-cta').href = '#apps';
    $('showcase-sticker').textContent = 'On iOS & Android.';
    $('word-count').textContent = edition.count;
    $('count-label').textContent = edition.countLabel;
    $('feature-intro').textContent = edition.intro;
    $('feature-audio').textContent = edition.audio;
    $('feature-playback').textContent = edition.playback;
    $('feature-offline').textContent = edition.offline;
    $('feature-footnote').textContent = edition.footnote;
    showSlide(0);
    if(updateUrl){const url=new URL(window.location.href);url.searchParams.set('language',code);history.replaceState(null,'',url);}
  }
  document.querySelectorAll('.language-button').forEach(button => button.addEventListener('click',() => setLanguage(button.dataset.language)));
  $('previous-slide').addEventListener('click',() => showSlide(slideIndex - 1));
  $('next-slide').addEventListener('click',() => showSlide(slideIndex + 1));
  $('device-stage').addEventListener('keydown',event => {
    if(event.key === 'ArrowLeft' || event.key === 'ArrowRight'){event.preventDefault();showSlide(slideIndex + (event.key === 'ArrowRight' ? 1 : -1));}
  });
  let touchStart = null;
  $('device-stage').addEventListener('touchstart',event => {touchStart={x:event.changedTouches[0].clientX,y:event.changedTouches[0].clientY};},{passive:true});
  $('device-stage').addEventListener('touchend',event => {
    if(!touchStart)return;
    const dx=event.changedTouches[0].clientX-touchStart.x,dy=event.changedTouches[0].clientY-touchStart.y;
    if(Math.abs(dx)>45&&Math.abs(dx)>Math.abs(dy))showSlide(slideIndex+(dx<0?1:-1));
    touchStart=null;
  },{passive:true});
  setLanguage(new URL(window.location.href).searchParams.get('language') === 'sv' ? 'sv' : 'fi',false);
})();
