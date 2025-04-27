class SignatureNotFoundError < StandardError; end

class DocumentsController < ApplicationController
  before_action :set_document, only: [ :download, :destroy ]

  rescue_from SignatureNotFoundError, with: :handle_signature_error

  def index
    documents = @current_user.documents.select(:id, :signed, :created_at)

    render json: documents.as_json(only: [ :id, :signed, :created_at ])
  end

  def create
    document = DocumentService.new(@current_user, params).create_and_sign_document

    render json: { document: document }, status: :created
  end

  def destroy
    delete_file(@document.file_path)
    delete_file(@document.signature_path)

    @document.destroy

    render json: { message: "Document successfully deleted." }, status: :ok
  end

  def download
    if File.exist?(@document.file_path)
      send_file @document.file_path, type: "application/pdf", disposition: "inline"
    else
      render json: { error: "File not found" }, status: :not_found
    end
  end

  def handle_signature_error(error)
    render json: { error: error.message }, status: :unprocessable_entity
  end

  private

  def set_document
    @document = @current_user.documents.find(params[:id])
  end

  def delete_file(path)
    File.delete(path) if path.present? && File.exist?(path)
  end
end
