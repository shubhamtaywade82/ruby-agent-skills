require "test_helper"

class AuthenticationTest < ActionDispatch::IntegrationTest
  test "dashboard requires authentication" do
    get "/dashboard"
    assert_response :redirect
  end

  test "dashboard renders for a signed-in user" do
    sign_in users(:one)
    get "/dashboard"
    assert_response :success
  end

  test "health stays public" do
    get "/health"
    assert_response :success
  end
end
