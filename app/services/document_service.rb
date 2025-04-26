class DocumentService
  def initialize(current_user, input)
    @current_user = current_user
    @input        = input
  end

  def create_and_sign_document
    # binding.pry
    pdf_path, signature_path = upload_files
    signature_coordinates    = extract_signature_coordinates

    document = create_document(pdf_path, signature_path)
    generate_signed_pdf(document, signature_coordinates)
  end

  private

  attr_reader :current_user, :input

  def upload_files
    pdf_file, signature_file = input.values_at(:file, :signature)
    [
      save_uploaded_file(pdf_file),
      save_uploaded_file(signature_file)
    ]
  end

  def generate_signed_pdf(document, signature_coordinates)
    SignedDocumentService.new(document, *signature_coordinates).generate_signed_pdf
  end

  def extract_signature_coordinates
    [
      input[:signature_x]&.to_i || 100,
      input[:signature_y]&.to_i || 100
    ]
  end

  def save_uploaded_file(file)
    path = Rails.root.join("storage", file.original_filename)
    File.open(path, "wb") { |f| f.write(file.read) }
    path.to_s
  end

  def create_document(pdf_path, signature_path)
    current_user.documents.create!(
      file_path: pdf_path,
      signature_path: signature_path,
      signed: false
    )
  end
end
