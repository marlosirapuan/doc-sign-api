require "test_helper"

class DocumentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(
      name: "User1",
      email: "user1example@test.com",
      password: "password123"
    )

    post login_url, params: { email: @user.email, password: "password123" }, as: :json
    @token = JSON.parse(response.body)["token"]

    @document = Document.create!(
      user: @user,
      file_path: Rails.root.join("test/fixtures/files/example.pdf").to_s,
      signature_path: Rails.root.join("test/fixtures/files/example_signature.png").to_s,
      signed: true
    )
  end

  test "should create a document with signature" do
    # Arrange
    pdf = fixture_file_upload("example.pdf", "application/pdf")
    signature = fixture_file_upload("example_signature.png", "image/png")

    # Act
    post documents_url,
      params: { file: pdf, signature: signature },
      headers: { Authorization: "Bearer #{@token}" }

    # Assert
    assert_response :created
    body = JSON.parse(response.body)
    assert body["document"].present?
  end

  test "should download the document successfully" do
    # Arrange & Act
    get download_document_url(@document), headers: { Authorization: "Bearer #{@token}" }

    # Assert
    assert_response :success
    assert_equal "application/pdf", response.media_type
  end

  test "should return 404 if file does not exist" do
    # Arrange
    @document = Document.create!(
      user: @user,
      file_path: Rails.root.join("test/fixtures/files/non_existent_file.pdf").to_s,
      signature_path: Rails.root.join("test/fixtures/files/non_existent_signature.png").to_s,
      signed: true
    )

    # Act
    get download_document_url(@document), headers: { Authorization: "Bearer #{@token}" }

    # Assert
    assert_response :not_found
    body = JSON.parse(response.body)
    assert_equal "File not found", body["error"]
  end
end
