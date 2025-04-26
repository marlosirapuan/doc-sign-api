class SignatureNotFoundError < StandardError; end

class DocumentsController < ApplicationController
  rescue_from SignatureNotFoundError, with: :handle_signature_error

  def index
    documents = @current_user.documents.select(:id, :signed, :created_at)

    render json: documents.as_json(only: [ :id, :signed, :created_at ])
  end

  def create
    pdf_path, signature_path = upload_files
    signature_coordinates    = extract_signature_coordinates

    document = create_document(pdf_path, signature_path)
    generate_signed_pdf(document, signature_coordinates)

    render json: { document: document }, status: :created
  end

  def download
    document = @current_user.documents.find(params[:id])

    if File.exist?(document.file_path)
      send_file document.file_path, type: "application/pdf", disposition: "inline"
    else
      render json: { error: "File not found" }, status: :not_found
    end
  end

  private

  def upload_files
    pdf_file, signature_file = params.values_at(:file, :signature)
    [
      save_uploaded_file(pdf_file),
      save_uploaded_file(signature_file)
    ]
  end

  def generate_signed_pdf(document, signature_coordinates)
    DocumentService.new(document, *signature_coordinates).generate_signed_pdf
  end

  def extract_signature_coordinates
    [
      params[:signature_x]&.to_i || 100,
      params[:signature_y]&.to_i || 100
    ]
  end

  def save_uploaded_file(file)
    path = Rails.root.join("storage", file.original_filename)
    File.open(path, "wb") { |f| f.write(file.read) }
    path.to_s
  end

  def create_document(pdf_path, signature_path)
    @current_user.documents.create!(
      file_path: pdf_path,
      signature_path: signature_path,
      signed: false
    )
  end

  def handle_signature_error(error)
    render json: { error: error.message }, status: :unprocessable_entity
  end
end
