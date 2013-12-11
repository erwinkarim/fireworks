require 'test_helper'

class LicserversControllerTest < ActionController::TestCase
  setup do
    @licserver = licservers(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:licservers)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create licserver" do
    assert_difference('Licserver.count') do
      post :create, licserver: { port: @licserver.port, server: @licserver.server }
    end

    assert_redirected_to licserver_path(assigns(:licserver))
  end

  test "should show licserver" do
    get :show, id: @licserver
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @licserver
    assert_response :success
  end

  test "should update licserver" do
    put :update, id: @licserver, licserver: { port: @licserver.port, server: @licserver.server }
    assert_redirected_to licserver_path(assigns(:licserver))
  end

  test "should destroy licserver" do
    assert_difference('Licserver.count', -1) do
      delete :destroy, id: @licserver
    end

    assert_redirected_to licservers_path
  end
end
