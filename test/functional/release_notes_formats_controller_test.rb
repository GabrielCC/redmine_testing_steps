require File.dirname(__FILE__) + '/../test_helper'

class TestingStepsFormatsControllerTest < ActionController::TestCase
  def setup
    @controller = TestingStepsFormatsController.new
  end

  def run_as_non_admin!
    @user = FactoryGirl.create(:user, :admin => false)
    @request.session[:user_id] = @user.id
  end

  test 'may not do anything with formats if not admin' do
    run_as_non_admin!

    get :new
    assert_response 403

    format = FactoryGirl.build(:testing_steps_format)
    post :create, :testing_steps_format => format
    assert_response 403
    assert_nil TestingStepsFormat.find_by_name(format.name)

    format.save!
    get :edit, :id => format.id
    assert_response 403

    [:update, :preview].each do |action|
      put action, :id => format.id, :testing_steps_format => format
      assert_response 403
    end
  end
end
