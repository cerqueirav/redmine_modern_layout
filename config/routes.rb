# Redmine Modern Layout
# Copyright (C) 2026 Victor Cerqueira <dev.cerqueirav@gmail.com>
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version. See the LICENSE file for details.

get 'admin/appearance', to: 'modern_layout#show', as: 'modern_layout_appearance'
post 'admin/appearance', to: 'modern_layout#update'
get 'admin/appearance/login_preview', to: 'modern_layout#login_preview', as: 'modern_layout_login_preview'
get 'modern_layout/theme/:digest', to: 'modern_layout#theme', as: 'modern_layout_theme',
                                   constraints: { digest: /[0-9a-f]{12}/ }, format: false
get 'modern_layout/asset/:kind/:name', to: 'modern_layout#asset', as: 'modern_layout_asset',
                                       constraints: { kind: /logo|favicon|login_bg|partners/, name: /[a-z_]+-\d+\.[a-z]+/ }, format: false
