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

RedmineApp::Application.routes.draw do
  get '/projects/:project_id/testing_steps',
    :to => 'testing_steps#index',
    :as => :testing_steps_overview

  resources :testing_steps,
    :only => [:create, :update, :destroy]

  get "/versions/:id/generate_testing_steps",
    :to => "testing_steps#generate",
    :as => :generate_testing_steps

  get 'testing_steps_formats/preview',
    :to => 'testing_steps_formats#preview',
    :as => :preview_testing_steps_format

  resources :testing_steps_formats,
    :except => [:index, :show]

  get 'settings/plugin/redmine_testing_steps?tab=formats',
    :to => 'settings#plugin',
    :as => :testing_steps_formats_tab
end
