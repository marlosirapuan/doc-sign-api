require "test_helper"

class DocumentServiceTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(
      name: "Test User",
      email: "test@example.com",
      password: "password123"
    )

    @pdf_file       = fixture_file_upload("example_pdf.pdf", "application/pdf")
    @signature_file = fixture_file_upload("example_signature.png", "image/png")

    @valid_input = {
      file: @pdf_file,
      signature: @signature_file,
      signature_x: "150",
      signature_y: "250"
    }
  end

  test "should create and sign a document successfully" do
    # Arrange
    service = DocumentService.new(@user, @valid_input)

    # Act & Assert
    assert_difference "Document.count", 1 do
      service.create_and_sign_document
    end

    # Assert
    document = Document.last
    assert document.signed, "Document should be signed"
    assert File.exist?(document.file_path), "Signed PDF file should exist"
    assert_includes document.file_path, "_signed.pdf"
  end

  test "should save uploaded files in storage directory" do
    # Arrange
    service = DocumentService.new(@user, @valid_input)

    # Act
    pdf_path, signature_path = service.send(:upload_files)

    # Assert
    assert File.exist?(pdf_path), "Uploaded PDF should exist in storage"
    assert File.exist?(signature_path), "Uploaded Signature should exist in storage"
  end
end
