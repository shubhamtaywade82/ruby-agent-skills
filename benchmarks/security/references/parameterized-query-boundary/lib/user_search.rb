# frozen_string_literal: true

class UserSearch
  def self.call(term, relation:)
    relation.where("name ILIKE ?", "%#{term}%")
  end
end
