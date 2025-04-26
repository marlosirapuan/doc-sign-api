require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "should be valid with valid attributes" do
    # Arrange
    user = users(:one)

    # Act & Assert
    assert user.valid?
  end

  test "should require name" do
    # Arrange
    user = User.new(email: "ua@example.com", password: "password123")

    # Act & Assert
    assert_not user.valid?
    assert_includes user.errors[:name], "can't be blank"
  end

  test "should require email" do
    # Arrange
    user = User.new(password: "password123")

    # Act & Assert
    assert_not user.valid?
    assert_includes user.errors[:email], "can't be blank"
  end

  test "should require password" do
    # Arrange
    user = User.new(email: "newuser@example.com")

    # Act & Assert
    assert_not user.valid?
    assert_includes user.errors[:password], "can't be blank"
  end
end
