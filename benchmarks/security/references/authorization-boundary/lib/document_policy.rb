# frozen_string_literal: true

class DocumentPolicy
  def initialize(user, document)
    @user = user
    @document = document
  end

  # Owner or administrator only; an absent user is denied rather than raising.
  def update?
    return false if @user.nil?

    @user.admin? || @document.owner_id == @user.id
  end
end
