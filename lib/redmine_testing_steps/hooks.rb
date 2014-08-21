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
  class Hooks < Redmine::Hook::ViewListener
    def view_issues_show_description_bottom(context)
      issue, controller = context[:issue], context[:controller]

      if issue.eligible_for_testing_steps?
        context[:testing_step] = issue.testing_step ||
          issue.build_testing_step
        controller.render_to_string(
          { :partial =>
              'hooks/testing_steps/view_issues_show_description_bottom',
            :locals => context }
        )
      else
        ""
      end
    end

    def view_versions_show_bottom(context)
      project, controller = context[:project], context[:controller]

      if project.module_enabled? :testing_steps
        controller.render_to_string(
          { :partial =>
            'hooks/testing_steps/version_show_bottom',
              :locals => context }
        )
      else
        ""
      end
    end 

    def view_layouts_base_html_head(context)
      stylesheet_link_tag('testing_steps.css',
                          :plugin => 'redmine_testing_steps')
    end
  end
end
