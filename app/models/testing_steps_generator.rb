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

class TestingStepsGenerator
  # for previewing formats
  class MockVersion
    class MockIssueCollection
      class MockIssue
        class MockTestingStep
          attr_reader :text
          def initialize(text)
            @text = text
          end
        end

        class MockThingWithName
          attr_reader :name
          def initialize(name)
            @name = name
          end
        end

        attr_reader :subject, :tracker, :project, :id

        def initialize(opts)
          opts.each { |k, v| instance_variable_set :"@#{k}", v }
        end

        def testing_step; MockTestingStep.new(@testing_step); end
        def tracker; MockThingWithName.new(@tracker); end
        def project; MockThingWithName.new(@project); end
      end

      def testing_steps_done; self; end

      # yields all the MockIssues to the passed block
      def find_each(&blk)
        [
          MockIssue.new(:subject => 'Crashes on startup',
            :tracker => 'Bug',
            :testing_step => 'Startup crashes no longer occur.',
            :project => 'Recipes app',
            :id => 37),
          MockIssue.new(:subject => 'Star recipes',
            :tracker => 'Feature',
            :testing_step => 'Favourite recipes can now be starred.',
            :project => 'Recipes app',
            :id => 23),
          MockIssue.new(:subject => 'Better performance when saving recipes',
            :tracker => 'Feature',
            :testing_step => 'Performance improved when saving recipes.',
            :project => 'Recipes app',
            :id => 15)
        ].each(&blk)
      end
    end

    def fixed_issues; MockIssueCollection.new; end
    def name; '1.0.0'; end
    def id; 8; end
    def description; 'Release candidate'; end
    def effective_date; Date.tomorrow; end
  end

  include Redmine::I18n # for format_date

  attr_reader :format, :version

  def initialize(version, format)
    @version = version
    @format = format
  end

  def generate
    generate_header << "\n" << generate_testing_steps
  end

  private
  def generate_header
    make_substitutions(format.header, values_for_header(version))
  end

  def generate_testing_steps
    str = format.start
    str << "\n"
    version.fixed_issues.testing_steps_done.find_each do |issue|
      str << make_substitutions(format.each_issue, values_for_issue(issue))
      str << "\n"
    end
    str << format.end
  end

  # TODO: Performance low-hanging fruit here: lazy load these values.
  # hash of values for the testing steps header
  def values_for_header(version)
    values = {
      "name" => version.name,
      "date" => format_date(version.effective_date),
      "description" => version.description,
      "id" => version.id
    }
    add_custom_values(version, values)
    values
  end

  # hash of values for the testing steps for a single issue
  def values_for_issue(issue)
    values = {
      "subject" => issue.subject,
      "testing_steps" => issue.testing_step ? issue.testing_step.text : "",
      "tracker" => issue.tracker.name,
      "project" => issue.project.name,
      "category" => issue.category ? issue.category.name : "",
      "id" => issue.id
    }
    add_custom_values(issue, values)
    values
  end

  def add_custom_values(object, values)
    object.custom_values.each do |cv|
      values[key_for_custom_value(cv)] = cv.value
    end
  end

  def key_for_custom_value(cv)
    "cf:#{cv.custom_field_id}"
  end

  # given a string containing placeholders like %{this} and a hash mapping
  # placeholders to values, substitute placeholders for values
  def make_substitutions(string, subs)
    string.gsub(/%\{.*?\}/) do |match|
      subs[match[2..-2]] || match[2..-2]
    end
  end
end
