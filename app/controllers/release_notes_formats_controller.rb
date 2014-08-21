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

class TestingStepsFormatsController < ApplicationController
  layout 'admin'
  before_filter :require_admin

  def new
    @format = TestingStepsFormat.new
  end

  def create
    @format = TestingStepsFormat.new(params[:testing_steps_format])
    if @format.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to testing_steps_formats_tab_path
    else
      render 'new'
    end
  end

  def edit
    @format = TestingStepsFormat.find(params[:id])
  end

  def update
    @format = TestingStepsFormat.find(params[:id])
    if @format.update_attributes(params[:testing_steps_format])
      flash[:notice] = l(:notice_successful_update)
      redirect_to testing_steps_formats_tab_path
    else
      render 'edit'
    end
  end

  def destroy
    @format = TestingStepsFormat.find(params[:id])
    @format.destroy
    flash[:notice] = l(:notice_successful_delete)
    redirect_to testing_steps_formats_tab_path
  end

  # we only expect this with :format => :js
  def preview
    format = TestingStepsFormat.new(params[:testing_steps_format])
    version = TestingStepsGenerator::MockVersion.new
    @text = TestingStepsGenerator.new(version, format).generate
    render :text => @text
  end
end
