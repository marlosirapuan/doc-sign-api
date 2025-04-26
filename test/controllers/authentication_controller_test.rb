require "test_helper"

class AuthenticationControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
  end

  test "should login and return token" do
    # Arrange & Act
    post login_url, params: { email: @user.email, password: "password123" }, as: :json

    # Assert
    assert_response :success

    body = JSON.parse(response.body)
    assert body["token"].present?
  end

  test "should not login with invalid credentials" do
    # Arrange & Act
    post login_url, params: { email: @user.email, password: "wrong_password" }, as: :json

    # Assert
    assert_response :unauthorized

    body = JSON.parse(response.body)
    assert_equal "Invalid email or password", body["error"]
  end
end
