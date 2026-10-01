# Redmine Modern Layout
# Copyright (C) 2026 Victor Cerqueira <dev.cerqueirav@gmail.com>
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version. See the LICENSE file for details.

module RedmineModernLayout
  # Numbers of the project overview dashboard. Every query starts from
  # Issue.visible, so users only count the issues they are allowed to see.
  class Dashboard
    FIELD_FORMATS = %w[list cascading_list bool enumeration].freeze
    WEEKS = 8
    TOP = 6

    attr_reader :project, :user, :today

    def initialize(project, user = User.current)
      @project = project
      @user = user
      @today = user.today
    end

    def with_subprojects?
      Setting.display_subprojects_issues?
    end

    def scope
      @scope ||= Issue.visible(user).where(project.project_condition(with_subprojects?))
    end

    def open_scope
      scope.open
    end

    # ---------- indicators ----------
    def counts
      @counts ||= {
        open: open_scope.count,
        overdue: open_scope.where("#{Issue.table_name}.due_date < ?", today).count,
        due_soon: open_scope.where(due_date: today..(today + 7)).count,
        unassigned: open_scope.where(assigned_to_id: nil).count,
        closed_month: scope.where(status_id: IssueStatus.where(is_closed: true).select(:id))
                           .where("#{Issue.table_name}.closed_on >= ?", today.beginning_of_month).count
      }
    end

    # [[status, count, color]] of the open issues, in the workflow order.
    def by_status
      @by_status ||= begin
        grouped = open_scope.group(:status_id).count
        statuses = IssueStatus.sorted.to_a
        statuses.each_with_index.filter_map do |status, i|
          count = grouped[status.id].to_i
          [status, count, Helper::STATUS_PALETTE[i % Helper::STATUS_PALETTE.size]] if count > 0
        end
      end
    end

    # Issues created and closed per week, oldest first: [[week_start, created, closed]].
    def trend
      @trend ||= begin
        first = today.beginning_of_week - (WEEKS - 1).weeks
        weeks = Array.new(WEEKS) { |i| first + i.weeks }
        created = scope.where("#{Issue.table_name}.created_on >= ?", first.beginning_of_day).pluck(:created_on)
        closed = scope.where("#{Issue.table_name}.closed_on >= ?", first.beginning_of_day)
                      .where(status_id: IssueStatus.where(is_closed: true).select(:id)).pluck(:closed_on)
        bucket = ->(times) { times.map { |t| user.time_to_date(t).beginning_of_week }.tally }
        c = bucket.call(created)
        d = bucket.call(closed)
        weeks.map { |w| [w, c[w].to_i, d[w].to_i] }
      end
    end

    # [[label, count, filter params]] of open issues by the field chosen in Appearance.
    def by_field
      @by_field ||= field ? by_custom_field : []
    end

    def field
      return @field if defined?(@field)
      id = RedmineModernLayout::Config.settings['dashboard_field'].to_s
      cf = id.present? ? IssueCustomField.find_by(id: id, field_format: FIELD_FORMATS) : nil
      @field = cf && cf.visible_by?(project, user) && project.all_issue_custom_fields.include?(cf) ? cf : nil
    end

    def by_custom_field
      values = CustomValue.where(customized_type: 'Issue', custom_field_id: field.id, customized_id: open_scope.select(:id))
                          .where.not(value: [nil, '']).group(:value).count
      rows = values.sort_by { |value, count| [-count, value.to_s] }.map do |value, count|
        [field.cast_value(value), count, { "cf_#{field.id}" => value }]
      end
      with_others(rows)
    end

    # Keeps the TOP rows and sums the rest in an "others" row: [:others, count, nil].
    def with_others(rows, keep = TOP)
      return rows if rows.size <= keep
      rows.first(keep - 1) + [[:others, rows.drop(keep - 1).sum { |row| row[1] }, nil]]
    end

    def by_tracker
      @by_tracker ||= by_tracker_rows
    end

    def by_tracker_rows
      grouped = open_scope.group(:tracker_id).count
      with_others(Tracker.where(id: grouped.keys).sorted.map { |t| [t, grouped[t.id], { 'tracker_id' => t.id }] }
                         .sort_by { |_, count, _| -count })
    end

    # [[principal or nil, count]], biggest first; nil = unassigned.
    def by_assignee
      @by_assignee ||= begin
        grouped = open_scope.group(:assigned_to_id).count
        unassigned = grouped.delete(nil).to_i
        principals = Principal.where(id: grouped.keys).index_by(&:id)
        rows = grouped.sort_by { |_, count| -count }.map { |id, count| [principals[id], count] }.select(&:first)
        rows = with_others(rows, unassigned > 0 ? TOP - 1 : TOP)
        rows << [nil, unassigned] if unassigned > 0
        rows
      end
    end

    # Open issues due in the next 14 days, overdue included.
    def deadlines
      @deadlines ||= open_scope.where.not(due_date: nil).where("#{Issue.table_name}.due_date <= ?", today + 14)
                               .includes(:project, :tracker, :status).reorder(:due_date, :id).limit(6).to_a
    end

    # [[project, {total:, open:, overdue:}]] for the visible child projects.
    def subprojects
      @subprojects ||= project.children.visible(user).sorted.to_a.map do |child|
        issues = Issue.visible(user).where(child.project_condition(with_subprojects?))
        open = issues.open
        [child, { total: issues.count, open: open.count,
                  overdue: open.where("#{Issue.table_name}.due_date < ?", today).count }]
      end
    end

    def activity
      @activity ||= Redmine::Activity::Fetcher.new(user, project: project, with_subprojects: with_subprojects?)
                                              .events(nil, nil, limit: 6)
    rescue StandardError
      []
    end
  end
end
