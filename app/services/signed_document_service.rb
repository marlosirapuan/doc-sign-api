require "prawn"
require "combine_pdf"

class SignedDocumentService
  SIGNATURE_WIDTH     = 200
  TEMP_SIGNATURE_FILE = "signature_temp.pdf"

  def initialize(document, signature_x = 100, signature_y = 100)
    @document    = document
    @signature_x = signature_x
    @signature_y = signature_y
  end

  def generate_signed_pdf
    validate_signature_path!

    signed_pdf_path = generate_signed_pdf_path
    signature_pdf_path = create_signature_pdf

    combine_and_save_pdfs(signature_pdf_path, signed_pdf_path)
    update_document(signed_pdf_path)
  ensure
    cleanup_temp_file(signature_pdf_path)
  end

  private

  def validate_signature_path!
    raise "Signature image not found" unless signature_image_exists?
  end

  def signature_image_exists?
    @document.signature_path && File.exist?(@document.signature_path)
  end

  def generate_signed_pdf_path
    @document.file_path.gsub(".pdf", "_signed.pdf")
  end

  def create_signature_pdf
    signature_pdf_path = Rails.root.join("storage", TEMP_SIGNATURE_FILE)

    Prawn::Document.generate(signature_pdf_path, page_size: "A4") do |pdf|
      pdf.image @document.signature_path, at: [ @signature_x, @signature_y ], width: SIGNATURE_WIDTH
    end

    signature_pdf_path
  end

  def combine_and_save_pdfs(signature_pdf_path, signed_pdf_path)
    combined_pdf = combine_pdfs(signature_pdf_path)
    combined_pdf.save(signed_pdf_path)
  end

  def combine_pdfs(signature_pdf_path)
    original_pdf  = CombinePDF.load(@document.file_path)
    signature_pdf = CombinePDF.load(signature_pdf_path)

    CombinePDF.new.tap do |combined|
      combined << original_pdf.pages[0]
      combined.pages[0] << signature_pdf.pages[0]
      original_pdf.pages[1..]&.each { |page| combined << page }
    end
  end

  def update_document(signed_pdf_path)
    @document.update!(file_path: signed_pdf_path, signed: true)
  end

  def cleanup_temp_file(file_path)
    File.delete(file_path) if file_path && File.exist?(file_path)
  end
end
