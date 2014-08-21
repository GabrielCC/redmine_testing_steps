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
  module VersionPatch
    def self.perform
      Version.class_eval do
        # number, 0 <= n <= 100, the proportion of this version's issues'
        # testing steps which are done
        def testing_steps_percent_completion
          required_count  = fixed_issues.testing_steps_required.count
          if required_count > 0
            done_count = fixed_issues.testing_steps_done.count
            100 * done_count / required_count
          else
            0
          end
        end

	def testing_steps_stats 
	  stats = Hash.new 
          stats[:required]     = fixed_issues.testing_steps_required.count 
          stats[:done]         = fixed_issues.testing_steps_done.count 
          stats[:done_empty]   = fixed_issues.done_but_testing_steps_nil.count 
          stats[:todo]         = fixed_issues.testing_steps_todo.count 
          stats[:not_required] = fixed_issues.testing_steps_not_required.count 
          stats[:none]         = fixed_issues.testing_steps_none.count 
          stats[:no_cf]        = fixed_issues.testing_steps_no_cf_defined.count 
          stats[:invalid]      = fixed_issues.testing_steps_invalid.count 
          stats[:nil]          = fixed_issues.testing_steps_custom_value_nil.count 
          stats[:total]        = issues_count 
          stats[:completion]   = testing_steps_percent_completion 

	  stats
        end 
      end
    end
  end
end
