# Redmine Modern Layout
# Copyright (C) 2026 Victor Cerqueira <dev.cerqueirav@gmail.com>
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version. See the LICENSE file for details.

require 'digest'
require 'json'

module RedmineModernLayout
  # Reads, validates and derives the appearance settings (stored in
  # Setting.plugin_redmine_modern_layout). Every value used in CSS/HTML is
  # validated here, so views can trust it.
  module Config
    HEX = /\A#[0-9a-fA-F]{6}\z/

    FONTS = {
      'system' => nil,
      'Inter' => 'Inter', 'Roboto' => 'Roboto', 'Open Sans' => 'Open+Sans', 'Lato' => 'Lato',
      'Nunito' => 'Nunito', 'Poppins' => 'Poppins', 'Source Sans 3' => 'Source+Sans+3',
      'Montserrat' => 'Montserrat', 'Ubuntu' => 'Ubuntu', 'Noto Sans' => 'Noto+Sans', 'IBM Plex Sans' => 'IBM+Plex+Sans'
    }.freeze
    SYSTEM_STACK = 'ui-sans-serif, system-ui, -apple-system, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif'.freeze

    PRESETS = {
      'emerald'  => { 'primary' => '#2f9e44', 'secondary' => '#0093c5', 'nav_bg' => '#fbfcfb', 'page_bg' => '#f4f7f5' },
      'indigo'   => { 'primary' => '#6d5dfc', 'secondary' => '#22d3ee', 'nav_bg' => '#fbfbfc', 'page_bg' => '#f6f7f9' },
      'ocean'    => { 'primary' => '#0284c7', 'secondary' => '#14b8a6', 'nav_bg' => '#f8fafc', 'page_bg' => '#f1f5f9' },
      'forest'   => { 'primary' => '#059669', 'secondary' => '#0ea5e9', 'nav_bg' => '#f7faf8', 'page_bg' => '#f3f6f4' },
      'graphite' => { 'primary' => '#fb923c', 'secondary' => '#f43f5e', 'nav_bg' => '#1e293b', 'page_bg' => '#f4f5f7' },
      'night'    => { 'primary' => '#8b5cf6', 'secondary' => '#ec4899', 'nav_bg' => '#111827', 'page_bg' => '#f5f5f7' },
      'rose'     => { 'primary' => '#e11d48', 'secondary' => '#f59e0b', 'nav_bg' => '#fffafb', 'page_bg' => '#faf6f7' }
    }.freeze

    LOGIN_STYLES = %w[split showcase card banner classic].freeze

    DEFAULTS = {
      'app_name' => '', 'show_name' => '1',
      'logo' => '', 'favicon' => '', 'login_bg' => '', 'partners' => '',
      'login_style' => 'split', 'login_title' => '', 'login_subtitle' => '',
      'login_headline' => '', 'login_text' => '', 'login_features' => '',
      'primary' => '#2f9e44', 'secondary' => '#0093c5', 'nav_bg' => '#fbfcfb', 'page_bg' => '#f4f7f5',
      'font' => 'Inter', 'font_size' => '14', 'radius' => '10', 'density' => 'comfortable',
      'footer_text' => '', 'footer_links' => '', 'footer_partners' => '0', 'show_powered_by' => '1',
      'theme_mode' => 'light', 'user_theme_switch' => '1',
      'dashboard' => '1', 'dashboard_field' => '', 'overview_time' => '1'
    }.freeze

    module_function

    def raw
      (Setting.plugin_redmine_modern_layout || {}).to_h.stringify_keys
    end

    # Validated settings, with defaults for missing/invalid values.
    def settings
      s = DEFAULTS.merge(raw.slice(*DEFAULTS.keys))
      %w[primary secondary nav_bg page_bg].each { |k| s[k] = DEFAULTS[k] unless s[k].to_s.match?(HEX) }
      s['font'] = DEFAULTS['font'] unless FONTS.key?(s['font'])
      s['font_size'] = clamp(s['font_size'], 12, 17, 14).to_s
      s['radius'] = clamp(s['radius'], 0, 20, 10).to_s
      s['density'] = 'comfortable' unless %w[comfortable compact].include?(s['density'])
      s['theme_mode'] = 'light' unless %w[light dark auto].include?(s['theme_mode'])
      %w[show_name show_powered_by user_theme_switch footer_partners dashboard overview_time].each { |k| s[k] = s[k].to_s == '1' ? '1' : '0' }
      s['login_style'] = 'split' unless LOGIN_STYLES.include?(s['login_style'])
      { 'login_title' => 80, 'login_subtitle' => 160, 'login_headline' => 120, 'login_text' => 300, 'login_features' => 400 }.each do |k, max|
        s[k] = s[k].to_s.strip[0, max]
      end
      %w[logo favicon login_bg partners].each { |k| s[k] = '' unless s[k].to_s.match?(/\A[a-z_]+-\d+\.(png|jpe?g|gif|webp|svg|ico)\z/) }
      s['dashboard_field'] = s['dashboard_field'].to_s.match?(/\A\d+\z/) ? s['dashboard_field'].to_s : ''
      s['app_name'] = s['app_name'].to_s.strip[0, 60]
      s['footer_text'] = s['footer_text'].to_s[0, 500]
      s
    end

    def clamp(value, min, max, default)
      Integer(value.to_s, 10).clamp(min, max)
    rescue ArgumentError
      default
    end

    def app_name
      settings['app_name'].presence || Setting.app_title
    end

    # "Label | https://url" per line -> [[label, url]] (http/https/mailto only).
    def footer_links
      settings['footer_links'].to_s.lines.map do |line|
        label, url = line.split('|', 2).map { |v| v.to_s.strip }
        next if label.blank? || url.blank?
        next unless url.match?(%r{\A(https?://|mailto:)}i)
        [label[0, 60], url[0, 300]]
      end.compact.first(8)
    end

    # Highlights on the login panel: one per line (max 4).
    def login_features
      settings['login_features'].to_s.lines.map { |l| l.strip[0, 90] }.reject(&:blank?).first(4)
    end

    def font_stack
      font = settings['font']
      font == 'system' ? SYSTEM_STACK : %("#{font}", #{SYSTEM_STACK})
    end

    def google_font_url
      family = FONTS[settings['font']]
      family && "https://fonts.googleapis.com/css2?family=#{family}:wght@400;500;600;700&display=swap"
    end

    # Changes whenever a setting changes: used to version the theme CSS URL.
    def digest
      Digest::SHA256.hexdigest(settings.to_json)[0, 12]
    end

    # ---------- colors ----------
    def rgb(hex)
      hex.delete('#').scan(/../).map { |c| c.to_i(16) }
    end

    def hex(rgb)
      '#' + rgb.map { |c| c.round.clamp(0, 255).to_s(16).rjust(2, '0') }.join
    end

    def mix(a, b, weight) # weight of a (0..1)
      hex(rgb(a).zip(rgb(b)).map { |x, y| (x * weight) + (y * (1 - weight)) })
    end

    def luminance(color)
      r, g, b = rgb(color).map do |c|
        c /= 255.0
        c <= 0.03928 ? c / 12.92 : ((c + 0.055) / 1.055)**2.4
      end
      (0.2126 * r) + (0.7152 * g) + (0.0722 * b)
    end

    def dark?(color)
      luminance(color) < 0.35
    end

    def contrast_text(color)
      dark?(color) ? '#ffffff' : '#111827'
    end

    # CSS custom properties for the light theme (dark theme tokens live in the stylesheet).
    def css_variables
      s = settings
      primary = s['primary']
      nav = s['nav_bg']
      nav_text = dark?(nav) ? '#e5e7eb' : '#3f4652'
      {
        '--mui-accent' => primary,
        '--mui-accent-hover' => mix(primary, '#000000', 0.86),
        '--mui-accent-soft' => mix(primary, '#ffffff', 0.12),
        '--mui-accent-contrast' => contrast_text(primary),
        '--mui-secondary' => s['secondary'],
        '--mui-bg' => s['page_bg'],
        '--mui-nav-bg' => nav,
        '--mui-nav-text' => nav_text,
        '--mui-nav-muted' => mix(nav_text, nav, 0.62),
        '--mui-nav-hover' => mix(nav_text, nav, 0.08),
        '--mui-nav-selected-bg' => dark?(nav) ? mix(primary, nav, 0.28) : mix(primary, '#ffffff', 0.12),
        '--mui-nav-selected-text' => dark?(nav) ? '#ffffff' : primary,
        '--mui-nav-border' => dark?(nav) ? mix('#ffffff', nav, 0.08) : '#e6e8ec',
        '--mui-font' => font_stack,
        '--mui-font-size' => "#{s['font_size']}px",
        '--mui-radius' => "#{s['radius']}px",
        '--mui-radius-sm' => "#{(s['radius'].to_i * 0.7).round}px"
      }
    end

    def theme_css
      vars = css_variables.map { |k, v| "  #{k}: #{v};" }.join("\n")
      dark_accent = settings['primary']
      <<~CSS
        /* Generated by Redmine Modern Layout from Administration > Appearance */
        :root {
        #{vars}
        }
        html[data-mui-theme="dark"] {
          --mui-accent-soft: #{mix(dark_accent, '#111827', 0.22)};
          --mui-accent-hover: #{mix(dark_accent, '#ffffff', 0.85)};
          --mui-nav-selected-bg: #{mix(dark_accent, '#0f172a', 0.28)};
          --mui-nav-selected-text: #ffffff;
        }
      CSS
    end
  end
end
