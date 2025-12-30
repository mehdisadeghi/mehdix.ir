(function() {
  const darkQuery = window.matchMedia('(prefers-color-scheme: dark)');
  const storageKey = 'theme';
  const toggle = document.getElementById('theme-toggle');

  function isDark() {
    const theme = document.documentElement.getAttribute('data-theme');
    return theme === 'dark' || (!theme && darkQuery.matches);
  }

  function updateIcon() {
    if (toggle) toggle.textContent = isDark() ? '☼' : '☀';
  }

  const saved = sessionStorage.getItem(storageKey);
  if (saved) {
    document.documentElement.setAttribute('data-theme', saved);
  }
  updateIcon();

  function toggleTheme() {
    const next = isDark() ? 'light' : 'dark';
    document.documentElement.setAttribute('data-theme', next);
    sessionStorage.setItem(storageKey, next);
    updateIcon();
  }

  toggle?.addEventListener('click', toggleTheme);
  document.querySelector('.post-title')?.addEventListener('click', toggleTheme);

  darkQuery.addEventListener('change', function() {
    if (!sessionStorage.getItem(storageKey)) {
      document.documentElement.removeAttribute('data-theme');
    }
    updateIcon();
  });

  // j/k navigation between posts (ت/ن in Persian layout)
  document.addEventListener('keydown', function(e) {
    if (e.target.matches('input, textarea')) return;
    const nav = document.querySelector('.pagination');
    if (!nav) return;
    if (e.key === 'j' || e.key === 'ت') nav.querySelector('a[title="j"]')?.click();
    if (e.key === 'k' || e.key === 'ن') nav.querySelector('a[title="k"]')?.click();
  });

  // Hue slider (` to toggle)
  const hueSlider = document.getElementById('hue-slider');
  if (hueSlider) {
    hueSlider.value = getComputedStyle(document.documentElement).getPropertyValue('--hue').trim();
    hueSlider.addEventListener('input', function(e) {
      document.documentElement.style.setProperty('--hue', e.target.value);
    });
    document.addEventListener('keydown', function(e) {
      if (e.key === '`' && !e.target.matches('input, textarea')) {
        e.preventDefault();
        hueSlider.classList.toggle('visible');
      }
    });
  }
})();
