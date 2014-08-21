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
  module IssuePatch
    def self.perform
      Issue.class_eval do
        has_one :testing_step, :dependent => :destroy

        # NB: the testing_steps_* scopes will not return issues which don't
        # have a value for the issue custom field.
        
        # all the issues which need testing steps (including ones which have
        # them already)
        def self.testing_steps_required
          done_value = Setting.plugin_redmine_testing_steps[:field_value_done]
          todo_value = Setting.plugin_redmine_testing_steps[:field_value_todo]
          joins_testing_steps.
            where('custom_values.value' => [done_value, todo_value])
        end

        # issues which still need testing steps
        def self.testing_steps_todo
          todo_value = Setting.plugin_redmine_testing_steps[:field_value_todo]
          joins_testing_steps.
            where('custom_values.value' => todo_value)
        end

        # issues whose testing steps are done
        def self.testing_steps_done
          done_value = Setting.plugin_redmine_testing_steps[:field_value_done]
          joins_testing_steps.
            where('custom_values.value' => done_value)
        end

        # issues whose testing steps are done
        def self.testing_steps_none
          none_value = Setting.plugin_redmine_testing_steps[:field_value_not_required]
          joins_testing_steps.
            where('custom_values.value' => none_value)
        end

        # issues whose testing steps are invalid
        def self.testing_steps_invalid
          todo_value = Setting.plugin_redmine_testing_steps[:field_value_todo]
          done_value = Setting.plugin_redmine_testing_steps[:field_value_done]
          none_value = Setting.plugin_redmine_testing_steps[:field_value_not_required] 

          joins_testing_steps.
            where('custom_values.value not in (?)', [done_value, todo_value,none_value])
        end

        def self.testing_steps_no_cf_defined
          includes(:custom_values).where(no_cf_defined_condition) 
        end

        # issues where CF is set to 'none' OR for which custom field is not defined
        def self.testing_steps_not_required
          cf_id = Setting.plugin_redmine_testing_steps[:issue_custom_field_id].to_i
          none_value = Setting.plugin_redmine_testing_steps[:field_value_not_required]
 
	  conditions = "( custom_values.custom_field_id = #{cf_id}"
	  conditions << " AND custom_values.value = '#{none_value}' )"

          includes(:custom_values).where( conditions + " OR " + no_cf_defined_condition ) 
        end

        # issues which don't have a custom value for testing steps
	# now it doesn't contain issues where cf is not defined
	# - those issues are qualified under testing_steps_not_required
        def self.testing_steps_custom_value_nil
          conditions = "( (custom_values.value IS NULL"
          conditions << " OR custom_values.value = '') )"

          joins_testing_steps.where(conditions)
        end

        # issues which have the testing steps custom field value set to 'done'
        # but no testing steps
        def self.done_but_testing_steps_nil
          conditions = "NOT EXISTS ("
          conditions << "SELECT 1 FROM testing_steps"
          conditions << " WHERE issue_id = issues.id"
          conditions << ")"
          testing_steps_done.where(conditions)
        end

        # can this issue have testing steps?
        # true if the issue has the configured custom field for testing steps
        def eligible_for_testing_steps?
          cf_id = Setting.
            plugin_redmine_testing_steps[:issue_custom_field_id].to_i
          available_custom_fields.include?(CustomField.find(cf_id))
        rescue ActiveRecord::RecordNotFound
          false
        end

        def testing_steps_done?
           cf = testing_steps_custom_value
           done_value = Setting.plugin_redmine_testing_steps[:field_value_done]
           cf.value == done_value unless cf.nil?
        rescue ActiveRecord::RecordNotFound
           false
        end

        # returns the CustomValue which describes the testing steps status for
        # this issue
        def testing_steps_custom_value
          cf_id = Setting.
            plugin_redmine_testing_steps[:issue_custom_field_id].to_i
          custom_values.find_by_custom_field_id(cf_id)
        end

        private
        def self.joins_testing_steps
          custom_field_id = Setting.
            plugin_redmine_testing_steps[:issue_custom_field_id]
          joins(:custom_values).
            where('custom_values.custom_field_id' => custom_field_id)
        end

	def self.no_cf_defined_condition
          cf_id = Setting.
            plugin_redmine_testing_steps[:issue_custom_field_id].to_i

          conditions_b = "NOT EXISTS ("
          conditions_b << "SELECT 1 FROM custom_values"
          conditions_b << " WHERE custom_values.customized_type = 'Issue'"
          conditions_b << " AND custom_values.custom_field_id = #{cf_id}"
          conditions_b << " AND custom_values.customized_id = issues.id"
          conditions_b << ") "
       	
	  conditions_b
	end 
      end
    end
  end
end
