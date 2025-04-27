require "test_helper"

class DocumentsControllerTest < ActionDispatch::IntegrationTest
  MIME_TYPES = {
    "pdf"  => "application/pdf",
    "docx" => "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
    "png"  => "image/png"
  }.freeze

  setup do
    @user = create_user_with_token

    @document_pdf = create_document("example_pdf.pdf", "example_signature.png",  MIME_TYPES["pdf"],  true)
    @document_doc = create_document("example_doc.docx", "example_signature.png", MIME_TYPES["docx"], true)
    @document     = create_document("example_pdf.pdf", "example_signature.png",  MIME_TYPES["pdf"],  true)
  end

  teardown do
    delete_document_files(@document)
  end

  private

  def create_user_with_token
    user = User.create!(
      name: "User1",
      email: "user1example@test.com",
      password: "password123"
    )

    post login_url, params: { email: user.email, password: "password123" }, as: :json
    @token = JSON.parse(response.body)["token"]
    user
  end

  def create_document(file_name, signature_name, mime_type, signed)
    file      = fixture_file_upload(file_name, mime_type)
    signature = fixture_file_upload(signature_name, MIME_TYPES["png"])

    @user.documents.create!(
      file_path: store_test_file(file),
      signature_path: store_test_file(signature),
      signed: signed
    )
  end

  def delete_document_files(document)
    File.delete(document.file_path) if File.exist?(document.file_path)
    File.delete(document.signature_path) if File.exist?(document.signature_path)
  end

  test "should list dcouments" do
    # Act
    get documents_url, headers: { Authorization: "Bearer #{@token}" }

    # Assert
    assert_response :success
    body = JSON.parse(response.body)

    assert body.is_a?(Array)
    assert_equal 3, body.size
    assert_equal @document_pdf.id, body.first["id"]
    assert_equal @document_pdf.signed, body.first["signed"]
    assert_equal @document_pdf.file_path, body.first["file_path"]
    assert body.first["created_at"].present?

    assert_equal 1, @document_pdf.versions.size
  end

  test "should return empty list if user has no documents" do
    # Arrange
    Document.delete_all

    # Act
    get documents_url, headers: { Authorization: "Bearer #{@token}" }

    # Assert
    assert_response :success
    body = JSON.parse(response.body)
    assert body.is_a?(Array)
    assert_empty body
  end

  test "[pdf] should create a document pdf with signature" do
    # Arrange
    pdf = fixture_file_upload("example_pdf.pdf", MIME_TYPES["pdf"])
    signature = fixture_file_upload("example_signature.png", MIME_TYPES["png"])

    # Act
    post documents_url,
      params: { file: pdf, signature: signature },
      headers: { Authorization: "Bearer #{@token}" }

    # Assert
    assert_response :created
    body = JSON.parse(response.body)
    assert body["document"].present?

    assert_equal 1, @document_pdf.versions.count
  end

  test "[docx] should create a document pdf with signature" do
    # Arrange
    pdf       = fixture_file_upload("example_doc.docx", MIME_TYPES["docx"])
    signature = fixture_file_upload("example_signature.png", MIME_TYPES["png"])

    # Act
    post documents_url,
      params: { file: pdf, signature: signature },
      headers: { Authorization: "Bearer #{@token}" }

    # Assert
    assert_response :created
    body = JSON.parse(response.body)
    assert body["document"].present?

    assert_equal 1, @document_pdf.versions.count
  end

  test "should download the document successfully" do
    # Arrange & Act
    get download_document_url(@document_pdf), headers: { Authorization: "Bearer #{@token}" }

    # Assert
    assert_response :success
    assert_equal "application/pdf", response.media_type
  end

  test "should return 404 if file does not exist" do
    # Arrange
    @document_pdf = Document.create!(
      user: @user,
      file_path: Rails.root.join("test/fixtures/files/non_existent_file.pdf").to_s,
      signature_path: Rails.root.join("test/fixtures/files/non_existent_signature.png").to_s,
      signed: true
    )

    # Act
    get download_document_url(@document_pdf), headers: { Authorization: "Bearer #{@token}" }

    # Assert
    assert_response :not_found
    body = JSON.parse(response.body)
    assert_equal "File not found", body["error"]
  end

  test "should destroy document and delete files" do
    assert File.exist?(@document.file_path), "PDF file should exist before delete"
    assert File.exist?(@document.signature_path), "Signature file should exist before delete"

    assert_difference "Document.count", -1 do
      delete document_url(@document), headers: { Authorization: "Bearer #{@token}" }
    end

    assert_response :success

    refute File.exist?(@document.file_path), "PDF file should be deleted after destroy"
    refute File.exist?(@document.signature_path), "Signature file should be deleted after destroy"
  end

  private

  def store_test_file(file)
    folder = Rails.root.join("storage")
    FileUtils.mkdir_p(folder) unless Dir.exist?(folder)

    path = folder.join(file.original_filename)
    File.open(path, "wb") { |f| f.write(file.read) }
    path.to_s
  end
end
