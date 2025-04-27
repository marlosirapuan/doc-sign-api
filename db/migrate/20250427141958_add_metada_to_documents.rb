class AddMetadaToDocuments < ActiveRecord::Migration[8.0]
  def change
    add_column :documents, :metadata, :json, default: {}
  end
end
