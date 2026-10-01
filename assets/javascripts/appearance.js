/*
 * Redmine Modern Layout
 * Copyright (C) 2026 Victor Cerqueira <dev.cerqueirav@gmail.com>
 * GNU General Public License v3 or later. See the LICENSE file.
 */
// Administration > Appearance: presets, color pickers and live preview.
(function () {
  'use strict';

  function rgb(hex) { return [1, 3, 5].map(function (i) { return parseInt(hex.substr(i, 2), 16); }); }
  function hex(c) { return '#' + c.map(function (v) { return Math.round(Math.max(0, Math.min(255, v))).toString(16).padStart(2, '0'); }).join(''); }
  function mix(a, b, w) { var x = rgb(a), y = rgb(b); return hex(x.map(function (v, i) { return v * w + y[i] * (1 - w); })); }
  function luminance(h) {
    return rgb(h).map(function (c) { c /= 255; return c <= 0.03928 ? c / 12.92 : Math.pow((c + 0.055) / 1.055, 2.4); })
      .reduce(function (acc, c, i) { return acc + c * [0.2126, 0.7152, 0.0722][i]; }, 0);
  }
  function isDark(h) { return luminance(h) < 0.35; }

  var SYSTEM = 'ui-sans-serif, system-ui, -apple-system, "Segoe UI", Roboto, Arial, sans-serif';

  function init() {
    var form = document.getElementById('mui-appearance-form');
    var preview = document.getElementById('mui-preview');
    if (!form || !preview) return;

    function val(name) {
      var el = form.querySelector('[name="settings[' + name + ']"]:checked') || form.querySelector('[name="settings[' + name + ']"]:not([type=hidden])');
      return el ? el.value : '';
    }

    function update() {
      var primary = val('primary'), nav = val('nav_bg'), page = val('page_bg');
      var navText = isDark(nav) ? '#e5e7eb' : '#3f4652';
      var p = preview.style;
      p.setProperty('--pv-accent', primary);
      p.setProperty('--pv-accent-soft', mix(primary, '#ffffff', 0.12));
      p.setProperty('--pv-accent-contrast', isDark(primary) ? '#ffffff' : '#111827');
      p.setProperty('--pv-nav', nav);
      p.setProperty('--pv-nav-text', navText);
      p.setProperty('--pv-nav-selected', isDark(nav) ? mix(primary, nav, 0.28) : mix(primary, '#ffffff', 0.12));
      p.setProperty('--pv-page', page);
      p.setProperty('--pv-radius', val('radius') + 'px');
      p.setProperty('--pv-font-size', val('font_size') + 'px');
      var font = val('font');
      p.setProperty('--pv-font', font === 'system' ? SYSTEM : '"' + font + '", ' + SYSTEM);
      preview.classList.toggle('mui-pv-compact', val('density') === 'compact');
      var name = val('app_name') || preview.dataset.defaultName;
      var nameEl = preview.querySelector('.mui-pv-name');
      if (nameEl) { nameEl.textContent = name; nameEl.hidden = !form.querySelector('[name="settings[show_name]"][type=checkbox]').checked; }
      var badge = preview.querySelector('.mui-pv-badge');
      if (badge) badge.textContent = (name || '?').charAt(0).toUpperCase();

      form.querySelectorAll('input.mui-color').forEach(function (input) {
        var code = input.parentNode.querySelector('.mui-color-code');
        if (code) code.textContent = input.value;
      });
      form.querySelectorAll('input[type=range]').forEach(function (input) {
        var out = form.querySelector('output[for="' + input.id + '"]');
        if (out) out.textContent = input.value + 'px';
      });
    }

    preview.dataset.defaultName = (preview.querySelector('.mui-pv-name') || {}).textContent || '';

    form.querySelectorAll('.mui-preset').forEach(function (btn) {
      btn.addEventListener('click', function () {
        var colors = JSON.parse(btn.getAttribute('data-colors'));
        Object.keys(colors).forEach(function (key) {
          var input = form.querySelector('input.mui-color[data-key="' + key + '"]');
          if (input) input.value = colors[key];
        });
        update();
      });
    });

    // Local preview of a newly chosen logo (before saving).
    var logoInput = form.querySelector('input[name="files[logo]"]');
    if (logoInput) {
      logoInput.addEventListener('change', function () {
        var file = logoInput.files && logoInput.files[0];
        if (!file) return;
        var url = URL.createObjectURL(file);
        var brand = preview.querySelector('.mui-pv-brand');
        var img = brand.querySelector('.mui-pv-logo');
        if (!img) {
          img = document.createElement('img');
          img.className = 'mui-pv-logo';
          img.alt = '';
          var badge = brand.querySelector('.mui-pv-badge');
          if (badge) badge.remove();
          brand.insertBefore(img, brand.firstChild);
        }
        img.src = url;
      });
    }

    // "See login page" opens the preview with the style currently selected (even before saving).
    var previewLink = document.getElementById('mui-login-preview-link');
    function updatePreviewLink() {
      if (previewLink) previewLink.href = previewLink.dataset.base + '?style=' + encodeURIComponent(val('login_style'));
    }
    form.addEventListener('change', updatePreviewLink);

    // Tabs: show one group of sections at a time; the whole form is saved together.
    var TAB_KEY = 'mui-appearance-tab';
    var links = document.querySelectorAll('[data-mui-tab-link]');
    var aside = document.querySelector('.mui-appearance-preview');
    var layout = document.querySelector('.mui-appearance');
    function showTab(key) {
      if (!document.querySelector('[data-mui-tab="' + key + '"]')) key = 'identity';
      form.querySelectorAll('fieldset[data-mui-tab]').forEach(function (fs) { fs.hidden = fs.getAttribute('data-mui-tab') !== key; });
      links.forEach(function (a) { a.classList.toggle('selected', a.getAttribute('data-mui-tab-link') === key); });
      var withPreview = aside && aside.getAttribute('data-mui-preview-tabs').split(' ').indexOf(key) !== -1;
      if (aside) aside.hidden = !withPreview;
      if (layout) layout.classList.toggle('mui-appearance-wide', !withPreview);
      try { sessionStorage.setItem(TAB_KEY, key); } catch (e) { /* ignore */ }
      if (history.replaceState) history.replaceState(null, '', '#' + key);
    }
    links.forEach(function (a) {
      a.addEventListener('click', function (e) { e.preventDefault(); showTab(a.getAttribute('data-mui-tab-link')); });
    });
    if (links.length) {
      var start = location.hash.replace('#', '');
      if (!start) { try { start = sessionStorage.getItem(TAB_KEY) || ''; } catch (e) { start = ''; } }
      showTab(start || 'identity');
    }

    form.addEventListener('input', update);
    form.addEventListener('change', update);
    update();
  }

  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', init);
  else init();
})();
