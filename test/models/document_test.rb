require "test_helper"

class DocumentTest < ActiveSupport::TestCase
  test "should be valid with valid attributes" do
    # Arrange
    document = documents(:one)

    # Assert
    assert document.valid?
  end

  test "should require file_path" do
    # Arrange
    document = Document.new(user: users(:one))

    # Assert
    assert_not document.valid?
    assert_includes document.errors[:file_path], "can't be blank"
  end
end
