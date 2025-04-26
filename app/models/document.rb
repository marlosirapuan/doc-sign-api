class Document < ApplicationRecord
  has_paper_trail

  belongs_to :user

  validates :file_path, presence: true
end
