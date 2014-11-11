require 'test_helper'

class FeatureHeadersControllerTest < ActionController::TestCase
  test "should get accordion_group" do
    get :accordion_group
    assert_response :success
  end

end
