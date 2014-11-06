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

class TestingStepsController < ApplicationController
  unloadable

  before_filter :find_version, :only => [:generate]
  before_filter :find_project, :only => [:index]

  helper :projects

  def index
    @with_subprojects = params[:with_subprojects].nil? ?
      Setting.display_subprojects_issues? : (params[:with_subprojects] == '1')

    @versions = @project.shared_versions || []
    @versions += @project.rolled_up_versions.visible if @with_subprojects
    @versions = @versions.uniq.sort

    # reject closed versions unless the user has specifically asked for them
    @versions.reject!(&:closed?) unless params[:closed]
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  # we only expect this to be called with :format => :js
  def create
    @issue = Issue.find(params[:testing_step][:issue_id])
    @testing_step = @issue.build_testing_step
    @testing_step.text = params[:testing_step][:text]

    if @testing_step.save
      update_custom_field(params[:mark_completed])
    end

    render 'update'
  end

  # we only expect this to be called with :format => :js
  def update
    @issue = Issue.find(params[:testing_step][:issue_id])
    @testing_step = @issue.testing_step
    @testing_step.text = params[:testing_step][:text]

    if @testing_step.save
      update_custom_field(params[:mark_completed])
    end

  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def destroy
    testing_step = TestingStep.find(params[:id])
    @issue = testing_step.issue

    update_custom_field(false)

    testing_step.destroy

    flash[:notice] = l(:notice_successful_delete)
    redirect_to @issue
  end

  def generate
    # for project menu
    @project = @version.project

    @format = testing_steps_format_from_params
    (render 'no_formats'; return) unless @format

    # for 'Also available in'
    @formats = TestingStepsFormat.select(:name).all

    @content = TestingStepsGenerator.new(@version, @format).generate

    if params[:raw]
      render :text => @content, :content_type => 'text/plain'
    elsif params[:download]
      send_data @content, :content_type => 'text/plain',
        :filename => "testing-steps-#{@project.name}-version-#{@version.name}.txt"
    end
  end

  private
  def find_version
    @version = Version.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_project
    @project = Project.find(params[:project_id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def update_custom_field(completed)
    new_value = Setting.plugin_redmine_testing_steps.
      fetch(completed ? :field_value_done : :field_value_todo)

    custom_value = @issue.testing_steps_custom_value

    # TODO: Maybe it would be better to just go ahead and create one, instead
    # of telling the user to do it manually
    if !custom_value
      @testing_step.errors.add(:base,
        t('testing_steps.errors.failed_find_custom_value'))
      return
    end

    if custom_value.value != new_value
       old_value = custom_value.value
       custom_value.value = new_value

       if custom_value.save
         # record the change to the custom field
         journal = @issue.init_journal(User.current)
         journal.details << JournalDetail.new(
           :property => 'cf',
           :prop_key => custom_value.custom_field_id,
           :old_value => old_value,
           :value => new_value)
         if !journal.save
           @testing_step.errors.add(:base,
             t('testing_steps.errors.failed_save_journal_entry_html').html_safe)
         end
       else
        @testing_step.errors.add(:base,
          t('testing_steps.errors.failed_save_custom_value_html').html_safe)
       end
    end
  end

  def testing_steps_format_from_params
    if (format_name = params[:testing_steps_format])
      format = TestingStepsFormat.find_by_name(format_name)
    end

    if format.nil?
      id = Setting.plugin_redmine_testing_steps[:default_generation_format_id]
      # dont raise RecordNotFound
      format = TestingStepsFormat.find_by_id(id)
    end

    # last resort -- just get the first one
    if format.nil?
      format = TestingStepsFormat.first
    end

    format
  end

end
