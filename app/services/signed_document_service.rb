require "prawn"
require "combine_pdf"

class SignedDocumentService
  SIGNATURE_WIDTH       = 200
  TEMP_SIGNATURE_FILE   = "signature_temp.pdf"
  TEMP_SIGNATURE_FOOTER = "signature_and_footer_temp.pdf"

  def initialize(document, signature_x = 350, signature_y = 750) # top right
    @document    = document
    @signature_x = signature_x
    @signature_y = signature_y
  end

  def generate_signed_pdf
    validate_signature_path!

    signed_pdf_path        = generate_signed_pdf_path
    signature_footer_paths = create_signature_and_footer_pdfs

    combine_and_save_pdfs(signature_footer_paths, signed_pdf_path)
    update_document(signed_pdf_path)
  ensure
    cleanup_temp_files(signature_footer_paths)
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

  def create_signature_and_footer_pdfs
    original_pdf = CombinePDF.load(@document.file_path)

    metadata         = @document.metadata || {}
    ip_info          = metadata["ip"] || "--"
    geolocation_info = metadata["geolocation"] || "--"
    footer_text      = "IP #{ip_info} | Geolocation #{geolocation_info}"
    temp_paths       = []

    original_pdf.pages.each_with_index do |_, index|
      temp_pdf_path = Rails.root.join("storage", "signature_and_footer_temp_#{index}.pdf")

      Prawn::Document.generate(temp_pdf_path, page_size: "A4") do |pdf|
        pdf.image @document.signature_path, at: [ @signature_x, @signature_y ], width: SIGNATURE_WIDTH
        pdf.bounding_box([ 0, 30 ], width: pdf.bounds.width, height: 30) do
          pdf.text footer_text, size: 8, align: :center
        end
      end
      temp_paths << temp_pdf_path
    end

    temp_paths
  end

  def combine_and_save_pdfs(signature_footer_paths, signed_pdf_path)
    original_pdf = CombinePDF.load(@document.file_path)

    CombinePDF.new.tap do |combined|
      original_pdf.pages.each_with_index do |page, index|
        signature_footer_pdf = CombinePDF.load(signature_footer_paths[index])
        combined_page = page
        combined_page << signature_footer_pdf.pages[0]
        combined << combined_page
      end
    end.save(signed_pdf_path)
  end

  def update_document(signed_pdf_path)
    @document.update!(file_path: signed_pdf_path, signed: true)
  end

  def cleanup_temp_files(paths)
    return unless paths

    paths.each do |path|
      File.delete(path) if path && File.exist?(path)
    end
  end
end
