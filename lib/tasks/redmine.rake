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

require 'yaml'

namespace :redmine do
  namespace :plugins do
    namespace :testing_steps do
      desc 'run all tests for testing steps plugin'
      task :test => 'redmine:plugins:testing_steps:test:all'

      namespace :test do
        def assumes_migrated_test_task(type)
          Rake::TestTask.new(type) do |t|
            t.libs << 'test'

            test_subdir = case type
            when :units
              'unit'
            when :functionals
              'functional'
            when :integration
              'integration'
            when :all
              '{unit,functional,integration}'
            end

            t.pattern =
              "plugins/redmine_testing_steps/test/#{test_subdir}/**/*_test.rb"
          end
        end

        desc 'run unit tests'
        assumes_migrated_test_task :units

        desc 'run functional tests'
        assumes_migrated_test_task :functionals

        desc 'run integration tests'
        assumes_migrated_test_task :integration

        desc 'run all tests'
        assumes_migrated_test_task :all
      end

      task :load_default_formats => :environment do
        fail 'you already have some formats! run with FORCE to force' unless
          TestingStepsFormat.count == 0 || ENV['FORCE']

        if File.exist?("plugins/redmine_testing_steps/config/formats.yml")
          # this person was using 1.2.0
          upgrading_from_120 = true
          source_file = "plugins/redmine_testing_steps/config/formats.yml"
        else
          source_file = "plugins/redmine_testing_steps/db/seeds.yml"
        end

        YAML.load_file(source_file).
          inject({}) {|h, (k,v)| h[k] = v; h[k][:name] ||= k.to_s; h }.
          values.each { |v| TestingStepsFormat.create!(v) }

        if upgrading_from_120
          puts "formats were successfully loaded into DB."
          puts "you may want to delete #{source_file} now."
        end
      end
    end
  end
end
