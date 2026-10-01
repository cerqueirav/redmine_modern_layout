/*
 * Redmine Modern Layout
 * Copyright (C) 2026 Victor Cerqueira <dev.cerqueirav@gmail.com>
 * GNU General Public License v3 or later. See the LICENSE file.
 */
(function () {
  function setCollapsed(on) {
    document.documentElement.classList.toggle('mui-nav-collapsed', on);
    try { localStorage.setItem('mui-nav-collapsed', on ? '1' : '0'); } catch (e) {}
  }

  $(document).on('click', '.js-mui-collapse', function () {
    setCollapsed(!document.documentElement.classList.contains('mui-nav-collapsed'));
  });

  // Light / dark mode switch (remembered per browser when allowed by the admin).
  $(document).on('click', '.js-mui-theme', function () {
    var root = document.documentElement;
    var next = root.dataset.muiTheme === 'dark' ? 'light' : 'dark';
    root.dataset.muiTheme = next;
    try { localStorage.setItem('mui-theme', next); } catch (e) {}
  });
  // "Automatic" mode follows the operating system while the user has no choice saved.
  if (window.matchMedia) {
    var mq = window.matchMedia('(prefers-color-scheme: dark)');
    var follow = function () {
      var root = document.documentElement, saved = null;
      try { saved = root.dataset.muiUserSwitch === '1' && localStorage.getItem('mui-theme'); } catch (e) {}
      if (!saved && root.dataset.muiMode === 'auto') root.dataset.muiTheme = mq.matches ? 'dark' : 'light';
    };
    if (mq.addEventListener) mq.addEventListener('change', follow);
  }

  $(document).on('click', '.js-mui-nav-toggle', function () {
    document.body.classList.toggle('mui-nav-open');
  });

  // "/" focuses the search box (outside text fields).
  $(document).on('keydown', function (e) {
    if (e.key !== '/' || e.ctrlKey || e.metaKey || e.altKey) return;
    var t = e.target;
    if (t.isContentEditable || /^(INPUT|TEXTAREA|SELECT)$/.test(t.tagName)) return;
    var q = document.getElementById('mui-q');
    if (q) { e.preventDefault(); setCollapsed(false); q.focus(); q.select(); }
  });

  // Status and priority shown as pills.
  function decorate(root) {
    $(root).find('table.list.issues td.status, table.list.issues td.priority').each(function () {
      if (this.querySelector('.mui-pill') || !this.textContent.trim()) return;
      $(this).wrapInner('<span class="mui-pill"></span>');
    });
    $(root).find('.issue.details .attributes .status.attribute .value, .issue.details .attributes .priority.attribute .value').each(function () {
      if (!this.querySelector('.mui-pill')) $(this).wrapInner('<span class="mui-pill"></span>');
    });
  }

  // Login: icons inside the fields and show / hide password button.
  var FIELD_ICONS = {
    username: '<circle cx="12" cy="8" r="4"/><path d="M4 21a8 8 0 0 1 16 0"/>',
    password: '<rect x="4" y="11" width="16" height="10" rx="2"/><path d="M8 11V7a4 4 0 0 1 8 0v4"/>',
    mail: '<rect x="3" y="5" width="18" height="14" rx="2"/><path d="m3 7 9 6 9-6"/>'
  };
  function svg(cls, paths) {
    return '<svg class="mui-icon ' + cls + '" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">' + paths + '</svg>';
  }
  var EYE = svg('mui-icon-eye', '<path d="M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7S2 12 2 12z"/><circle cx="12" cy="12" r="3"/>') +
    svg('mui-icon-eye-off', '<path d="M10.7 5.1A10 10 0 0 1 12 5c6.5 0 10 7 10 7a17 17 0 0 1-2.2 3.2M6.6 6.6C3.6 8.4 2 12 2 12s3.5 7 10 7a9.7 9.7 0 0 0 5.4-1.6M9.9 9.9a3 3 0 0 0 4.2 4.2M2 2l20 20"/>');

  function initAuthFields() {
    var wrapper = document.querySelector('#wrapper.mui-auth');
    if (!wrapper) return;
    Object.keys(FIELD_ICONS).forEach(function (id) {
      var input = wrapper.querySelector('#content input#' + id);
      if (!input || input.parentNode.classList.contains('mui-field')) return;
      var box = document.createElement('span');
      box.className = 'mui-field';
      input.parentNode.insertBefore(box, input);
      box.appendChild(input);
      var icon = document.createElement('span');
      icon.className = 'mui-field-icon';
      icon.innerHTML = svg('', FIELD_ICONS[id]); // markup fixo
      box.insertBefore(icon, input);
      if (input.type !== 'password') return;
      var btn = document.createElement('button');
      btn.type = 'button';
      btn.className = 'mui-pw-toggle';
      btn.innerHTML = EYE; // markup fixo
      btn.title = wrapper.dataset.pwShow;
      btn.setAttribute('aria-label', btn.title);
      btn.addEventListener('click', function () {
        var show = input.type === 'password';
        input.type = show ? 'text' : 'password';
        box.classList.toggle('is-visible', show);
        btn.title = show ? wrapper.dataset.pwHide : wrapper.dataset.pwShow;
        btn.setAttribute('aria-label', btn.title);
        input.focus();
      });
      box.appendChild(btn);
    });
  }

  $(function () {
    initAuthFields();
    decorate(document);
    new MutationObserver(function (muts) {
      muts.forEach(function (m) { m.addedNodes.forEach(function (n) { if (n.nodeType === 1) decorate(n); }); });
    }).observe(document.getElementById('content') || document.body, { childList: true, subtree: true });
  });
})();
