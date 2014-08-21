require File.dirname(__FILE__) + '/../test_helper'

class IssueHookTest < ActionController::TestCase
  def setup
    @controller = IssuesController.new

    # create a testing step
    @testing_step = FactoryGirl.create(:testing_step,
                                      :text => "product can now do backflips")
    @issue = @testing_step.issue
    @project = @issue.project

    # create a user
    @user = FactoryGirl.create(:user)

    # give him the permission to view issues in @project
    role = FactoryGirl.create(:role, :permissions => %w(view_issues))
    member = Member.new(:role_ids => [role.id], :user_id => @user.id)
    @project.members << member
    @project.save!

    # log him in
    @request.session[:user_id] = @user.id
  end

  def assert_testing_steps_displayed
    assert_response :success
    assert_select '#testing-steps',
      :text => /product can now do backflips/
  end

  def assert_testing_steps_not_displayed
    assert_response :success
    assert_select '#testing-steps', false
  end

  test 'testing steps displayed if issue eligible' do
    Issue.any_instance.stubs(:eligible_for_testing_steps?).returns(true)

    get :show, :id => @issue.id
    assert_testing_steps_displayed
  end

  test 'testing steps not displayed if issue not eligible' do
    Issue.any_instance.stubs(:eligible_for_testing_steps?).returns(false)

    get :show, :id => @issue.id
    assert_testing_steps_not_displayed
  end
end
