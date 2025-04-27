class Document < ApplicationRecord
  has_paper_trail

  store_accessor :metadata, :ip, :geolocation

  belongs_to :user

  validates :file_path, presence: true
end
