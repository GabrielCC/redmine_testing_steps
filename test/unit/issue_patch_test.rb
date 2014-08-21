require File.dirname(__FILE__) + '/../test_helper.rb'

class IssuePatchTest < ActiveSupport::TestCase
  test "issues return correct value for testing_steps_done?" do
    # TODO
  end

  test 'should only be eligible for testing steps when project and tracker are setup' do
    # create a tracker which is enabled for testing steps
    enabled_tracker = FactoryGirl.create(:tracker)
    Setting.stubs(:plugin_redmine_testing_steps).
      returns({:enabled_tracker_ids => [enabled_tracker.id]})
    # create a project which is enabled for testing steps
    enabled_project = FactoryGirl.create(:project_with_testing_steps,
                                 :trackers => [enabled_tracker])

    issue = FactoryGirl.build(:issue)
    issue.tracker = enabled_tracker
    issue.project = enabled_project
    assert issue.eligible_for_testing_steps?,
      "issue should be eligible for testing steps"

    tracker = FactoryGirl.create(:tracker)
    issue.tracker = tracker
    assert !issue.eligible_for_testing_steps?,
      "issue should not be eligible for testing steps because of the tracker"

    issue.tracker = enabled_tracker
    issue.project = FactoryGirl.create(:project)
    assert !issue.eligible_for_testing_steps?,
      "issue should not be eligible for testing steps because of the project"
  end
end
