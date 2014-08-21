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

class DoEverythingForVersion131 < ActiveRecord::Migration
  def up
    # remove testing_steps.status => now a custom field
    remove_column :testing_steps, :status

    # don't allow nulls in testing_steps.text
    change_table :testing_steps do |t|
      t.change :text, :text, :null => false
    end
  end

  def down
    change_table :testing_steps do |t|
      t.column :status,   :string,  :limit => 12
      t.change :text,     :text,    :limit => nil,  :null => true
    end

    add_index :testing_steps, :status
  end
end
