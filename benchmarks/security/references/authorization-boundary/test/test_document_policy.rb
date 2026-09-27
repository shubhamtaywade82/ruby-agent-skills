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
  def setup
    @document = Document.new(1)
  end

  def test_owner_is_authorized
    assert DocumentPolicy.new(User.new(id: 1, admin: false), @document).update?
  end

  def test_admin_is_authorized
    assert DocumentPolicy.new(User.new(id: 2, admin: true), @document).update?
  end

  def test_unrelated_user_is_denied
    refute DocumentPolicy.new(User.new(id: 2, admin: false), @document).update?
  end

  def test_missing_user_is_denied
    refute DocumentPolicy.new(nil, @document).update?
  end
end
