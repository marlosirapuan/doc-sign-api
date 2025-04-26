require "test_helper"

class ApplicationControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(
      name: "Test User",
      email: "testuser@example.com",
      password: "password123"
    )
    @token = JsonWebToken.encode(user_id: @user.id)
  end

  test "should allow access with valid token" do
    # Arrage & Act
    get documents_path, headers: { Authorization: "Bearer #{@token}" }

    # Assert
    assert_response :success
  end

  test "should deny access with missing token" do
    # Arrange & Act
    get documents_path

    # Assert
    assert_response :unauthorized
    body = JSON.parse(response.body)
    assert_equal "Unauthorized", body["error"]
  end

  test "should deny access with invalid token" do
    # Arrange & Act
    get documents_path, headers: { Authorization: "Bearer invalidToken" }

    # Assert
    assert_response :unauthorized
    body = JSON.parse(response.body)
    assert_equal "Unauthorized", body["error"]
  end
end
