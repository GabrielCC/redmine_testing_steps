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

module RedmineTestingSteps
  module SettingsControllerPatch
    def self.perform
      SettingsController.class_eval do
        helper 'testing_steps_settings'

        # tells Rails to render the 'testing steps settings' view instead of the
        # standard plugin settings view if the plugin we're looking at is the
        # testing steps one
        def plugin_with_testing_steps_patch
          if params[:id] == 'redmine_testing_steps'
            plugin_redmine_testing_steps
          else
            plugin_without_testing_steps_patch
          end
        end

        def plugin_redmine_testing_steps
          if request.get?
            @settings = Setting.plugin_redmine_testing_steps
            @formats = TestingStepsFormat.all
            render 'plugin_testing_steps'
          elsif request.post?
            # if params looks ok, update settings in the db
            if (params[:settings] &&
              params[:settings][:default_generation_format_id].to_i > 0)
              plugin_without_testing_steps_patch
            else
              # otherwise just GET the settings again
              redirect_to plugin_settings_path(:id => 'redmine_testing_steps')
            end
          else
            render_404
          end
        end

        alias_method_chain :plugin, :testing_steps_patch
      end
    end
  end
end
