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

  test "should create a version when document is updated" do
    # Arrange
    document = Document.create!(
      user: users(:one),
      file_path: "old_file_path.pdf",
      signature_path: "signature_path.png",
      signed: true
    )
    original_file_path = document.file_path

    # Act
    document.update!(file_path: "new_file_path.pdf")

    # Assert
    assert_equal 2, document.versions.size
    assert_equal original_file_path, document.versions.last.reify.file_path
  end

  test "should not create a version when document is not changed" do
    # Arrange
    document = documents(:one)

    # Act
    document.touch

    # Assert
    assert_equal 1, document.versions.size
  end
end
