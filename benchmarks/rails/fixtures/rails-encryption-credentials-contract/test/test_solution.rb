# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/solution"

class EncryptionCredentialsContractTest < Minitest::Test
  def test_missing_master_key_fails_closed
    error = assert_raises(KeyError) do
      CredentialStore.new(
        environment: :production,
        credentials: { production: { api_key: "secret" } },
        master_key: nil
      ).fetch(:api_key)
    end

    assert_equal "missing master key", error.message
  end

  def test_secret_is_not_exposed_by_logging
    store = CredentialStore.new(
      environment: :production,
      credentials: { production: { api_key: "super-secret" } },
      master_key: "master"
    )

    refute_includes store.log_value(:api_key), "super-secret"
  end

  def test_encrypted_round_trip_uses_randomized_ciphertext
    attribute = EncryptedAttribute.new(key: "master")

    first = attribute.write("classified")
    second = attribute.write("classified")

    refute_equal first, second
    assert_equal "classified", attribute.read(first)
  end

  def test_rotation_reencrypts_with_the_new_key
    old_attribute = EncryptedAttribute.new(key: "old")
    rotated = KeyRotation.new(encrypted_attribute: old_attribute).rotate(
      ciphertext: old_attribute.write("classified"),
      new_key: "new"
    )

    assert_equal "classified", EncryptedAttribute.new(key: "new").read(rotated)
  end
end
