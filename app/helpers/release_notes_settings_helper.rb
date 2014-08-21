# Copyright (C) 2014-2015 Gabriel Croitoru
# This file is a part of redmine_testing_steps.

# redmine_testing_steps is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by the Free
# Software Foundation, either version 3 of the License, or (at your option) any
# later version.

# redmine_testing_steps is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
# details.

# You should have received a copy of the GNU General Public License along with
# redmine_testing_steps. If not, see <http://www.gnu.org/licenses/>.

module TestingStepsSettingsHelper
  def testing_steps_settings_tabs
    [
      {:name => 'general',
        :partial => 'settings/testing_steps_general',
        :label => :label_general},
      {:name => 'formats',
        :partial => 'settings/testing_steps_formats',
        :label => 'testing_steps.formats.title'}
    ]
  end

  def options_for_testing_steps_issue_custom_field(settings)
    custom_fields = IssueCustomField.where(:field_format => 'list')
    selected = settings['issue_custom_field_id'].to_i
    options_from_collection_for_select(custom_fields, 'id', 'name', selected)
  end

  def options_for_testing_steps_issue_custom_field_value(settings, selected)
    custom_field = CustomField.find(settings['issue_custom_field_id'].to_i)
    values = custom_field.possible_values
    options_for_select(values, selected)
  rescue ActiveRecord::RecordNotFound
    []
  end
end
