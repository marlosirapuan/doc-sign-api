require "test_helper"

class SignedDocumentServiceTest < ActiveSupport::TestCase
  setup do
    user = User.create!(
      name: "User One",
      email: "user1test@example.com",
      password: "password123"
    )

    @document = Document.create!(
      user: user,
      file_path: Rails.root.join("test/fixtures/files/example.pdf").to_s,
      signature_path: Rails.root.join("test/fixtures/files/example_signature.png").to_s,
      signed: false
    )
  end

  test "should generate a signed pdf" do
    # Arrange
    service = SignedDocumentService.new(@document, 150, 250)

    # Act
    service.generate_signed_pdf
    signed_file = @document.file_path

    # puts @document.file_path

    # Assert
    assert File.exist?(signed_file), "Signed PDF should exist"
    assert @document.reload.signed, "Document should be marked as signed"
    assert_includes signed_file, "_signed.pdf"
  end

  test "should raise error when signature image is missing" do
    # Arrange
    user = User.create!(
      name: "User Two",
      email: "user2test@example.com",
      password: "password123"
    )

    # Act
    document_without_signature = Document.create!(
      user: user,
      file_path: Rails.root.join("test/fixtures/files/example.pdf").to_s,
      signature_path: nil,
      signed: false
    )

    service = SignedDocumentService.new(document_without_signature)

    # Assert
    error = assert_raises(RuntimeError) { service.generate_signed_pdf }

    assert_equal "Signature image not found", error.message
  end
end
