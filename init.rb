# Copyright (C) 2012-2013 Harry Garrood
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

require 'redmine'
require 'redmine_testing_steps/hooks'

ActionDispatch::Callbacks.to_prepare do
  # Patches to the Redmine core.
  patched_classes = %w(issue issues_controller settings_controller version)
  patched_classes.each do |core_class|
    require_dependency core_class
    "RedmineTestingSteps::#{core_class.camelize}Patch".constantize.perform
  end
end

Redmine::Plugin.register :redmine_testing_steps do
  name 'Redmine testing steps plugin'
  author 'Gabriel Croitoru'
  description 'A plugin for managing testing steps.'
  version '1.0.0'
  author_url 'http://gabrielcc.github.io/'
  requires_redmine :version_or_higher => '2.1.0'

  # the partial won't be used, but can't be blank, because Redmine needs to
  # think this plugin is configurable
  settings :default => {
      :default_generation_format_id => 1,
      :issue_custom_field_id => 0,
      :field_value_todo => 'Todo',
      :field_value_done => 'Done',
      :field_value_not_required => 'Not required'
    },
    :partial => 'not_blank'

  project_module :redmine_testing_steps do
    permission :redmine_testing_steps,
      { :redmine_testing_steps => [:index, :new, :generate] },
      :public => true
  end

end
