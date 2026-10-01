# Redmine Modern Layout
# Copyright (C) 2026 Victor Cerqueira <dev.cerqueirav@gmail.com>
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version. See the LICENSE file for details.

module RedmineModernLayout
  module Helper
    # Line icons (2px stroke, 24x24 grid, Lucide style).
    ICONS = {
      'home'      => '<path d="M3 10.5 12 3l9 7.5"/><path d="M5 9.5V21h14V9.5"/><path d="M10 21v-6h4v6"/>',
      'dashboard' => '<rect x="3" y="3" width="7" height="9" rx="1.5"/><rect x="14" y="3" width="7" height="5" rx="1.5"/><rect x="14" y="12" width="7" height="9" rx="1.5"/><rect x="3" y="16" width="7" height="5" rx="1.5"/>',
      'check'     => '<rect x="3" y="3" width="18" height="18" rx="4"/><path d="m8 12 3 3 5-6"/>',
      'folder'    => '<path d="M3 7a2 2 0 0 1 2-2h4l2 2h8a2 2 0 0 1 2 2v8a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/>',
      'activity'  => '<path d="M3 12h4l3-8 4 16 3-8h4"/>',
      'list'      => '<path d="M9 6h12M9 12h12M9 18h12"/><path d="m3 6 1 1 2-2M3 12l1 1 2-2M3 18l1 1 2-2"/>',
      'plus'      => '<path d="M12 5v14M5 12h14"/>',
      'clock'     => '<circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/>',
      'gantt'     => '<path d="M3 3v18h18"/><path d="M7 7h8M9 12h9M7 17h6"/>',
      'calendar'  => '<rect x="3" y="5" width="18" height="16" rx="2"/><path d="M3 10h18M8 3v4M16 3v4"/>',
      'news'      => '<path d="M4 5h13v14a2 2 0 0 0 2 2H6a2 2 0 0 1-2-2z"/><path d="M17 9h3v10a2 2 0 0 1-2 2"/><path d="M8 9h5M8 13h5M8 17h3"/>',
      'file'      => '<path d="M14 3H6a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V9z"/><path d="M14 3v6h6M8 13h8M8 17h5"/>',
      'book'      => '<path d="M4 4.5A1.5 1.5 0 0 1 5.5 3H20v15H5.5A1.5 1.5 0 0 0 4 19.5z"/><path d="M4 19.5A1.5 1.5 0 0 0 5.5 21H20v-3"/>',
      'chat'      => '<path d="M21 12a8 8 0 0 1-11.6 7.1L4 20l1-4.4A8 8 0 1 1 21 12z"/>',
      'paperclip' => '<path d="m21 11-8.5 8.5a5 5 0 0 1-7-7L14 4a3.5 3.5 0 0 1 5 5l-8.5 8.5a2 2 0 0 1-3-3L15 7"/>',
      'git'       => '<circle cx="6" cy="6" r="2.5"/><circle cx="6" cy="18" r="2.5"/><circle cx="18" cy="8" r="2.5"/><path d="M6 8.5v7M18 10.5c0 4-6 3-10.5 6"/>',
      'settings'  => '<circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.7 1.7 0 0 0 .3 1.8l.1.1a2 2 0 1 1-2.8 2.8l-.1-.1a1.7 1.7 0 0 0-1.8-.3 1.7 1.7 0 0 0-1 1.5V21a2 2 0 1 1-4 0v-.1a1.7 1.7 0 0 0-1.1-1.5 1.7 1.7 0 0 0-1.8.3l-.1.1a2 2 0 1 1-2.8-2.8l.1-.1a1.7 1.7 0 0 0 .3-1.8 1.7 1.7 0 0 0-1.5-1H3a2 2 0 1 1 0-4h.1a1.7 1.7 0 0 0 1.5-1.1 1.7 1.7 0 0 0-.3-1.8l-.1-.1a2 2 0 1 1 2.8-2.8l.1.1a1.7 1.7 0 0 0 1.8.3H9a1.7 1.7 0 0 0 1-1.5V3a2 2 0 1 1 4 0v.1a1.7 1.7 0 0 0 1 1.5 1.7 1.7 0 0 0 1.8-.3l.1-.1a2 2 0 1 1 2.8 2.8l-.1.1a1.7 1.7 0 0 0-.3 1.8V9a1.7 1.7 0 0 0 1.5 1H21a2 2 0 1 1 0 4h-.1a1.7 1.7 0 0 0-1.5 1z"/>',
      'kanban'    => '<rect x="3" y="3" width="18" height="18" rx="2"/><path d="M8 7v7M12 7v4M16 7v10"/>',
      'flag'      => '<path d="M5 21V4M5 4h11l-2 4 2 4H5"/>',
      'shield'    => '<path d="M12 3 4 6v6c0 5 3.5 8 8 9 4.5-1 8-4 8-9V6z"/>',
      'search'    => '<circle cx="11" cy="11" r="7"/><path d="m20 20-3.5-3.5"/>',
      'logout'    => '<path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4M16 17l5-5-5-5M21 12H9"/>',
      'user'      => '<circle cx="12" cy="8" r="4"/><path d="M4 21a8 8 0 0 1 16 0"/>',
      'menu'      => '<path d="M4 6h16M4 12h16M4 18h16"/>',
      'sidebar'   => '<rect x="3" y="4" width="18" height="16" rx="2"/><path d="M9 4v16"/>',
      'help'      => '<circle cx="12" cy="12" r="9"/><path d="M9.5 9a2.5 2.5 0 1 1 3.5 2.3c-.6.3-1 .9-1 1.6V14M12 17.5h.01"/>',
      'check-mark' => '<path d="m5 12.5 4.5 4.5L19 7.5"/>',
      'dot'       => '<circle cx="12" cy="12" r="3"/>',
      'moon'      => '<path d="M21 12.8A9 9 0 1 1 11.2 3a7 7 0 0 0 9.8 9.8z"/>',
      'sun'       => '<circle cx="12" cy="12" r="4"/><path d="M12 2v2M12 20v2M4.9 4.9l1.4 1.4M17.7 17.7l1.4 1.4M2 12h2M20 12h2M4.9 19.1l1.4-1.4M17.7 6.3l1.4-1.4"/>'
    }.freeze

    # Redmine menu item name -> icon.
    MENU_ICONS = {
      overview: 'home', activity: 'activity', roadmap: 'flag', issues: 'list',
      new_issue: 'plus', new_object: 'plus', time_entries: 'clock', gantt: 'gantt',
      calendar: 'calendar', news: 'news', documents: 'file', wiki: 'book',
      boards: 'chat', files: 'paperclip', repository: 'git', settings: 'settings',
      projects: 'folder', display_menu_link: 'kanban', administration: 'shield',
      my_page: 'dashboard', home: 'home', help: 'help'
    }.freeze

    STATUS_PALETTE = %w[#3b82f6 #f59e0b #10b981 #8b5cf6 #64748b #ef4444 #ec4899 #14b8a6 #f97316 #0ea5e9].freeze

    # Login, lost password and registration use the full-screen login design.
    def mui_auth_page?
      return false if mui_login_style == 'classic'
      return true if @mui_login_preview
      controller.is_a?(AccountController) && %w[login lost_password register activation_email].include?(action_name)
    end

    # The preview (Administration > Appearance) may show a style that is not saved yet.
    def mui_login_style
      style = @mui_login_style.to_s
      RedmineModernLayout::Config::LOGIN_STYLES.include?(style) ? style : RedmineModernLayout::Config.settings['login_style']
    end

    def mui_login_page?
      @mui_login_preview || action_name == 'login'
    end

    # { 'field' => [operator, values] } -> issue list query parameters.
    def mui_issue_filters(filters)
      params = { set_filter: 1, f: [], op: {}, v: {} }
      filters.each do |field, (operator, values)|
        params[:f] << field
        params[:op][field] = operator
        params[:v][field] = Array(values).map(&:to_s) if values
      end
      params[:f] << ''
      params
    end

    def mui_asset_url(kind)
      name = RedmineModernLayout::Config.settings[kind]
      name.present? ? modern_layout_asset_path(kind: kind, name: name) : nil
    end

    def mui_favicon_tag
      name = RedmineModernLayout::Config.settings['favicon']
      return favicon if name.blank?
      tag(:link, rel: 'icon', href: modern_layout_asset_path(kind: 'favicon', name: name))
    end

    def mui_icon(name, size: 18)
      paths = ICONS[name] || ICONS['dot']
      %(<svg class="mui-icon mui-icon-#{name}" width="#{size}" height="#{size}" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">#{paths}</svg>).html_safe
    end

    def mui_nav_link(label, url, icon, selected: false, html: {})
      classes = ['mui-nav-link', html.delete(:class)]
      classes << 'selected' if selected
      link_to(url, html.merge(class: classes.compact.join(' '), title: label)) do
        mui_icon(icon) + content_tag(:span, label, class: 'mui-label')
      end
    end

    # Main menu items (project or application menu), with icons.
    def mui_main_menu_links(project)
      menu = project && !project.new_record? ? :project_menu : :application_menu
      links = []
      menu_items_for(menu, project) do |node|
        caption, url, selected = extract_node_details(node, project)
        next if url.blank?
        html = node.html_options(selected: selected).except(:class)
        links << mui_nav_link(caption, url, MENU_ICONS[node.name] || 'dot', selected: selected, html: html)
      end
      safe_join(links)
    end

    def mui_color_for(key)
      hue = key.to_s.each_char.sum { |c| c.ord * 31 } % 360
      "hsl(#{hue} 62% 52%)"
    end

    def mui_badge(text, key)
      content_tag(:span, text.to_s.strip[0].to_s.upcase, class: 'mui-badge', style: "background:#{mui_color_for(key)}")
    end

    def mui_sidebar_projects
      return [] unless User.current.logged? || !Setting.login_required?
      Project.visible.where(status: Project::STATUS_ACTIVE).sorted.limit(30).to_a
    end

    def mui_status_css
      rules = IssueStatus.sorted.each_with_index.map do |status, i|
        "body.mui .status-#{status.id}{--mui-status:#{STATUS_PALETTE[i % STATUS_PALETTE.size]}}"
      end
      content_tag(:style, rules.join("\n").html_safe)
    end

    def mui_user_initials(user)
      [user.firstname, user.lastname].map { |n| n.to_s[0] }.join.upcase.presence || user.login.to_s[0].to_s.upcase
    end

    # html_title may receive strings or arrays; the first item is the most specific.
    def mui_page_title
      Array(@html_title).flatten.compact.map(&:to_s).find(&:present?)
    end

    def mui_can_add_issue?(project)
      if project && !project.new_record?
        User.current.allowed_to?(:add_issues, project)
      else
        User.current.allowed_to?(:add_issues, nil, global: true)
      end
    end
  end
end
