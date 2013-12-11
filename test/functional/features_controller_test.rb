require 'test_helper'

class FeaturesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get show" do
    get :show
    assert_response :success
  end

  test "should get monthly" do
    get :monthly
    assert_response :success
  end

end
