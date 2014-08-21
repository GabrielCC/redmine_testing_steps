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

class DoEverythingForVersion130 < ActiveRecord::Migration
  def up
    change_table :testing_steps do |t|
      t.column :status,   :string,  :limit => 12
      t.change :text,     :text,    :limit => nil,  :null => true
    end

    add_index :testing_steps, :status
    add_index :testing_steps, :issue_id

    create_table :testing_steps_formats do |t|
      t.string :name,         :null => false
      t.string :header,       :null => false
      t.string :each_issue,   :null => false
      t.string :start,        :null => false
      t.string :end,          :null => false
    end

    add_index :testing_steps_formats, :name, :unique => true
  end

  def down
    # don't bother with changing the type of testing_steps.text back
    remove_column :testing_steps, :status
    remove_index :testing_steps, :name => 'index_testing_steps_on_issue_id'
    drop_table :testing_steps_formats
  end
end
