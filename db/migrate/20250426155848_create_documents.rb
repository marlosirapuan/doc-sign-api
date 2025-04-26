class CreateDocuments < ActiveRecord::Migration[8.0]
  def change
    create_table :documents do |t|
      t.references :user, null: false, foreign_key: true
      t.string :file_path
      t.string :signature_path
      t.boolean :signed

      t.timestamps
    end
  end
end
