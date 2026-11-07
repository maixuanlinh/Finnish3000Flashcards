'use strict';
(() => {
  const toggle = document.querySelector('.menu-toggle');
  const nav = document.getElementById('main-nav');
  if (!toggle || !nav) return;
  const close = () => { toggle.setAttribute('aria-expanded','false'); nav.classList.remove('open'); };
  toggle.addEventListener('click',() => { const open=toggle.getAttribute('aria-expanded')!=='true'; toggle.setAttribute('aria-expanded',String(open)); nav.classList.toggle('open',open); });
  nav.querySelectorAll('a').forEach(link => link.addEventListener('click',close));
  document.addEventListener('keydown',event => { if(event.key==='Escape'&&toggle.getAttribute('aria-expanded')==='true'){ close(); toggle.focus(); } });
})();
