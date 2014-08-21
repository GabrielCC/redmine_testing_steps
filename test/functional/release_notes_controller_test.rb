require File.dirname(__FILE__) + '/../test_helper'

class TestingStepsControllerTest < ActionController::TestCase
  def setup
    @controller = TestingStepsController.new

    # run as an admin
    @user = FactoryGirl.create(:user, :admin => true)
    @request.session[:user_id] = @user.id

    # create a format
    FactoryGirl.create(:testing_steps_format)
  end

  # create a project with 3 issues with testing steps todo, 4 done, and 5
  # not required, all assigned to the same version
  def make_a_version_with_some_issues_and_testing_steps
    tracker = FactoryGirl.create(:tracker)
    project = FactoryGirl.create(:project_with_testing_steps,
                                 :trackers => [tracker])
    TestingStep.stubs(:enabled_tracker_ids).returns([tracker.id])
    version = FactoryGirl.create(:version, :project => project)
    [[3, 'todo'], [4, 'done'], [5, 'not_required']].each do |n, status|
      n.times do
        issue = FactoryGirl.create(:issue,
                                   :project => project,
                                   :fixed_version => version,
                                   :tracker => tracker)
        issue.build_testing_step
        issue.testing_step.status = status
        issue.testing_step.text = 'LULZ' # so that it's valid
        issue.testing_step.save!
      end
    end
    version
  end

  test "don't try to generate without any formats" do
    TestingStepsFormat.destroy_all
    assert_equal TestingStepsFormat.count, 0,
      "this test will only work if there are no formats in the db"

    version = FactoryGirl.create(:version_with_testing_steps)

    get :generate, :id => version.id
    assert_template 'no_formats'
  end

  test "should use default format when not specified" do
    version = FactoryGirl.create(:version_with_testing_steps)
    format = FactoryGirl.create(:testing_steps_format)

    Setting.stubs(:plugin_redmine_testing_steps).
      returns(:default_generation_format_id => format.id)

    get :generate, :id => version.id
    assert_template 'generate'
    assert_equal assigns(:format), format
  end

  test "should use default format when specified format not found" do
    version = FactoryGirl.create(:version_with_testing_steps)
    format = FactoryGirl.create(:testing_steps_format)

    Setting.stubs(:plugin_redmine_testing_steps).
      returns(:default_generation_format_id => format.id)

    get :generate, :id => version.id, :testing_steps_format => 'garbage'
    assert_template 'generate'
    assert_equal assigns(:format), format
  end

  test "should use specified format" do
    version = FactoryGirl.create(:version_with_testing_steps)
    format = FactoryGirl.create(:testing_steps_format)

    # ensure the format is not retrieved from settings
    Setting.stubs(:plugin_redmine_testing_steps).
      returns(:default_generation_format_id => 0)

    get :generate, :id => version.id, :testing_steps_format => format.name
    assert_template 'generate'
    assert_equal assigns(:format), format
  end

  test 'should warn if some issues still need testing steps' do
    version = make_a_version_with_some_issues_and_testing_steps
    get :generate, :id => version.id

    # there should be 3 issues needing testing steps
    assert_response :success
    assert_select 'div.flash.warning',
      :text => /3/
  end
end
