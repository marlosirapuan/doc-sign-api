class DocumentsController < ApplicationController
  def index
    render json: Document.all
  end
end
