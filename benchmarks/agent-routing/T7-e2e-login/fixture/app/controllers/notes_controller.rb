class NotesController < ApplicationController
  before_action :require_login

  def index
    respond_to do |format|
      format.html
      format.json { render json: current_user.notes.order(:id).map { |note| { id: note.id, body: note.body } } }
    end
  end

  def create
    note = current_user.notes.new(body: params.require(:note).fetch(:body, ""))
    if note.save
      render json: { id: note.id, body: note.body }, status: :created
    else
      errors = note.errors.map { |error| { attribute: error.attribute, type: error.type, message: error.message } }
      render json: { errors: errors }, status: :unprocessable_content
    end
  end
end
