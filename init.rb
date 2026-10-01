# Redmine Modern Layout
# Copyright (C) 2026 Victor Cerqueira <dev.cerqueirav@gmail.com>
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version. See the LICENSE file for details.

require_relative 'lib/redmine_modern_layout/config'
require_relative 'lib/redmine_modern_layout/helper'
require_relative 'lib/redmine_modern_layout/dashboard'

Redmine::Plugin.register :redmine_modern_layout do
  name 'Redmine Modern Layout'
  author 'Victor Cerqueira'
  author_url 'mailto:dev.cerqueirav@gmail.com'
  description 'Modern, customizable layout for Redmine: sidebar navigation, top bar, card-based content, ' \
              'login page styles, project overview dashboard, logo, colors, fonts, footer and dark mode ' \
              '(Administration > Appearance).'
  version '0.1.0'
  url 'https://github.com/cerqueirav/redmine_modern_layout'
  requires_redmine version_or_higher: '6.0'

  # Values are edited in Administration > Appearance (the partial only links there).
  settings default: {}, partial: 'settings/modern_layout_settings'

  menu :admin_menu, :modern_layout_appearance, { controller: 'modern_layout', action: 'show' },
       caption: :mui_appearance, html: { class: 'icon icon-settings' }, icon: 'settings'
end

ActiveSupport.on_load(:action_controller_base) do
  helper RedmineModernLayout::Helper
end
