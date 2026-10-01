# Redmine Modern Layout
# Copyright (C) 2026 Victor Cerqueira <dev.cerqueirav@gmail.com>
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version. See the LICENSE file for details.

# Administration > Appearance (settings + uploads) and delivery of the generated
# theme CSS and uploaded images.
class ModernLayoutController < ApplicationController
  layout 'admin'

  KINDS = %w[logo favicon login_bg partners].freeze
  MAX_BYTES = { 'logo' => 1.megabyte, 'favicon' => 512.kilobytes, 'login_bg' => 5.megabytes, 'partners' => 2.megabytes }.freeze
  MIME = { 'png' => 'image/png', 'jpg' => 'image/jpeg', 'jpeg' => 'image/jpeg', 'gif' => 'image/gif',
           'webp' => 'image/webp', 'svg' => 'image/svg+xml', 'ico' => 'image/x-icon' }.freeze
  TEXT_KEYS = %w[app_name show_name primary secondary nav_bg page_bg font font_size radius density
                 footer_text footer_links footer_partners show_powered_by theme_mode user_theme_switch
                 login_style login_title login_subtitle login_headline login_text login_features
                 dashboard dashboard_field overview_time].freeze

  # The login page and the "change your password" page also use the theme.
  # (raise: false: not every Redmine version has every filter, e.g. 2FA in 4.2.)
  %i[check_if_login_required check_password_change check_twofa_activation].each do |filter|
    skip_before_action filter, only: [:theme, :asset], raise: false
  end
  before_action :require_admin, only: [:show, :update, :login_preview]

  def show
    @settings = RedmineModernLayout::Config.settings
  end

  def update
    values = RedmineModernLayout::Config.raw
    TEXT_KEYS.each do |key|
      values[key] = params[:settings][key].to_s if params[:settings]&.key?(key)
    end
    errors = []
    KINDS.each do |kind|
      if params.dig(:remove, kind) == '1'
        delete_file(values[kind])
        values[kind] = ''
      end
      file = params.dig(:files, kind)
      next if file.blank?
      name, error = store_upload(kind, file)
      if error
        errors << error
      else
        delete_file(values[kind])
        values[kind] = name
      end
    end
    Setting.plugin_redmine_modern_layout = values
    if errors.any?
      flash[:error] = errors.join(' ')
    else
      flash[:notice] = l(:notice_successful_update)
    end
    redirect_to modern_layout_appearance_path
  end

  # The real login page redirects logged-in users: this shows it to the admin.
  def login_preview
    @mui_login_preview = true
    @mui_login_style = params[:style].to_s
    render template: 'account/login', layout: 'base'
  end

  def theme
    expires_in 1.year, public: true # the URL contains a digest of the settings
    render plain: RedmineModernLayout::Config.theme_css, content_type: 'text/css'
  end

  def asset
    kind = params[:kind].to_s
    name = RedmineModernLayout::Config.settings[kind]
    return head(:not_found) unless KINDS.include?(kind) && name.present? && name == params[:name]

    path = File.join(storage_dir, name)
    return head(:not_found) unless File.file?(path)

    # Uploaded SVGs must never run scripts, even if opened directly.
    response.headers['Content-Security-Policy'] = "default-src 'none'; img-src data:; style-src 'unsafe-inline'; sandbox"
    response.headers['X-Content-Type-Options'] = 'nosniff'
    expires_in 1.year, public: true
    send_file path, type: MIME[File.extname(name).delete('.')], disposition: 'inline'
  end

  private

  def storage_dir
    File.join(Attachment.storage_path, 'modern_layout')
  end

  def delete_file(name)
    return if name.blank? || name.include?('/')
    path = File.join(storage_dir, name)
    File.delete(path) if File.file?(path)
  end

  # Returns [stored_name, nil] or [nil, error_message].
  def store_upload(kind, file)
    ext = File.extname(file.original_filename.to_s).delete('.').downcase
    return [nil, l(:mui_error_file_type, name: file.original_filename)] unless MIME.key?(ext)
    return [nil, l(:mui_error_file_size, name: file.original_filename)] if file.size > MAX_BYTES[kind]

    data = file.read
    return [nil, l(:mui_error_file_type, name: file.original_filename)] unless valid_content?(ext, data)

    FileUtils.mkdir_p(storage_dir)
    name = "#{kind}-#{Time.now.to_i}.#{ext}"
    File.binwrite(File.join(storage_dir, name), data)
    [name, nil]
  end

  # Checks the real content (magic bytes), not only the extension.
  def valid_content?(ext, data)
    head = data.byteslice(0, 16).to_s.b
    case ext
    when 'png' then head.start_with?("\x89PNG".b)
    when 'jpg', 'jpeg' then head.start_with?("\xFF\xD8\xFF".b)
    when 'gif' then head.start_with?('GIF8'.b)
    when 'webp' then head.byteslice(0, 4) == 'RIFF'.b && head.byteslice(8, 4) == 'WEBP'.b
    when 'ico' then head.start_with?("\x00\x00\x01\x00".b)
    when 'svg'
      text = data.to_s.dup.force_encoding('UTF-8')
      text.valid_encoding? && text.match?(/<svg[\s>]/i) &&
        !text.match?(/<script|<foreignObject|\son\w+\s*=|javascript:|<iframe|<embed|<object/i)
    else false
    end
  end
end
