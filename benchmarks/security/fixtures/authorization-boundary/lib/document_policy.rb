# frozen_string_literal: true

class DocumentPolicy
  def initialize(user, document)
    @user = user
    @document = document
  end

  def update?
    @user.admin? || @document.owner_id == @user.id
  end
end
