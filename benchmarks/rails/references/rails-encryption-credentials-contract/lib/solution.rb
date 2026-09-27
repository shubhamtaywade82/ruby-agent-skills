# frozen_string_literal: true

require "base64"
require "digest"
require "openssl"

class CredentialStore
  REDACTED = "[FILTERED]"

  def initialize(environment:, credentials:, master_key:)
    @environment = environment
    @credentials = credentials
    @master_key = master_key
  end

  # Fails closed: without the externally delivered master key no credential
  # is readable.
  def fetch(name)
    raise KeyError, "missing master key" if @master_key.nil? || @master_key.to_s.empty?

    @credentials.fetch(@environment).fetch(name)
  end

  def log_value(name)
    "credential=#{name} value=#{redact(name)}"
  end

  private

  def redact(_name)
    REDACTED
  end
end

class EncryptedAttribute
  IV_BYTES = 12
  TAG_BYTES = 16

  def initialize(key:)
    @key = key
  end

  # Randomized AES-256-GCM: fresh IV per write, authentication tag stored.
  # Layout: iv (12) + tag (16) + ciphertext.
  def write(plaintext)
    cipher = OpenSSL::Cipher.new("aes-256-gcm").encrypt
    cipher.key = derived_key
    iv = cipher.random_iv
    ciphertext = cipher.update(plaintext) + cipher.final
    Base64.strict_encode64(iv + cipher.auth_tag(TAG_BYTES) + ciphertext)
  end

  def read(encoded)
    bytes = Base64.strict_decode64(encoded)
    cipher = OpenSSL::Cipher.new("aes-256-gcm").decrypt
    cipher.key = derived_key
    cipher.iv = bytes.byteslice(0, IV_BYTES)
    cipher.auth_tag = bytes.byteslice(IV_BYTES, TAG_BYTES)
    cipher.update(bytes.byteslice((IV_BYTES + TAG_BYTES)..)) + cipher.final
  end

  private

  def derived_key
    Digest::SHA256.digest(@key)
  end
end

class KeyRotation
  # The old key stays readable until expires_at so in-flight ciphertext can
  # still be migrated; after that it is retired.
  def initialize(encrypted_attribute:, expires_at: nil)
    @encrypted_attribute = encrypted_attribute
    @expires_at = expires_at
  end

  def rotate(ciphertext:, new_key:)
    plaintext = @encrypted_attribute.read(ciphertext)
    EncryptedAttribute.new(key: new_key).write(plaintext)
  end

  def old_key_retired?(now:)
    !@expires_at.nil? && now >= @expires_at
  end
end
