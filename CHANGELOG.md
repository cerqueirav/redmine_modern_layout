# Changelog

## 0.1.0

* First release.
* Layout: collapsible side navigation with icons and the project tree, search box with the `/` shortcut,
  top bar with breadcrumbs and a "New issue" button, card-based content, status and priority pills.
* Administration > Appearance, organized in tabs, with live preview: system name, logo, favicon,
  7 predefined themes, primary / secondary / menu / page colors, 12 fonts, base text size, corner radius,
  density, light / dark / automatic mode with a per-user switch, footer text, links and partner banner.
* Login page in 5 styles (Split, Showcase, Card, Partner banner, Classic), with configurable texts,
  background image, partner banner, icons in the fields and a show / hide password button; preview for administrators.
* Project overview dashboard: indicators linked to filtered issue lists, issues by status, created × closed
  over 8 weeks, by tracker, by a chosen custom field, by assignee, upcoming deadlines, recent activity
  and subprojects as cards. Option to hide the time tracking block.
* Uploads checked by content (not only by extension); SVG files with scripts are refused and images are
  served with a sandbox Content-Security-Policy.
* Sample images in `docs/samples` (official Redmine logo and fictional partners).
* Translations: en, pt-BR, pt, es, fr, it, de, ru, ja, zh.
* Tested on Redmine 6.0.5 and 6.1.5.
