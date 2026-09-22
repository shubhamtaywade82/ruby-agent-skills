# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/document_policy"

User = Struct.new(:id, :admin, keyword_init: true) do
  def admin?
    admin
  end
end

Document = Struct.new(:owner_id)

class DocumentPolicyTest < Minitest::Test
  def test_owner_and_admin_are_authorized
    document = Document.new(1)
    assert DocumentPolicy.new(User.new(id: 1, admin: false), document).update?
    assert DocumentPolicy.new(User.new(id: 2, admin: true), document).update?
    refute DocumentPolicy.new(User.new(id: 2, admin: false), document).update?
  end
end
