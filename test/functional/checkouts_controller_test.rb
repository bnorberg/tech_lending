require 'test_helper'

class CheckoutsControllerTest < ActionController::TestCase
  setup do
    @checkout = checkouts(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:checkouts)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create checkout" do
    assert_difference('Checkout.count') do
      post :create, checkout: { date: @checkout.date, duration: @checkout.duration, end_time: @checkout.end_time, id: @checkout.id, item_id: @checkout.item_id, patron_college: @checkout.patron_college, patron_status: @checkout.patron_status, renewals: @checkout.renewals, start_time: @checkout.start_time }
    end

    assert_redirected_to checkout_path(assigns(:checkout))
  end

  test "should show checkout" do
    get :show, id: @checkout
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @checkout
    assert_response :success
  end

  test "should update checkout" do
    put :update, id: @checkout, checkout: { date: @checkout.date, duration: @checkout.duration, end_time: @checkout.end_time, id: @checkout.id, item_id: @checkout.item_id, patron_college: @checkout.patron_college, patron_status: @checkout.patron_status, renewals: @checkout.renewals, start_time: @checkout.start_time }
    assert_redirected_to checkout_path(assigns(:checkout))
  end

  test "should destroy checkout" do
    assert_difference('Checkout.count', -1) do
      delete :destroy, id: @checkout
    end

    assert_redirected_to checkouts_path
  end
end
