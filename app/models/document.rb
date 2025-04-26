class Document < ApplicationRecord
  belongs_to :user

  validates :file_path, presence: true
end
