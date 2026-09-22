# frozen_string_literal: true

require "base64"
require "digest"
require "openssl"

class CredentialStore
  def initialize(environment:, credentials:, master_key:)
    @environment = environment
    @credentials = credentials
    @master_key = master_key
  end

  def fetch(name)
    @credentials.fetch(@environment).fetch(name)
  end

  def log_value(name)
    "credential=#{name} value=#{fetch(name)}"
  end
end

class EncryptedAttribute
  def initialize(key:)
    @key = key
  end

  def write(plaintext)
    cipher = OpenSSL::Cipher.new("aes-256-gcm")
    cipher.encrypt
    cipher.key = Digest::SHA256.digest(@key)
    cipher.iv = "fixed-iv-should-not-be-used"
    ciphertext = cipher.update(plaintext) + cipher.final
    Base64.strict_encode64(cipher.iv + ciphertext)
  end

  def read(encoded)
    bytes = Base64.strict_decode64(encoded)
    cipher = OpenSSL::Cipher.new("aes-256-gcm")
    cipher.decrypt
    cipher.key = Digest::SHA256.digest(@key)
    cipher.iv = bytes[0, 12]
    cipher.update(bytes[12..]) + cipher.final
  end
end

class KeyRotation
  def initialize(encrypted_attribute:)
    @encrypted_attribute = encrypted_attribute
  end

  def rotate(ciphertext:, new_key:)
    plaintext = @encrypted_attribute.read(ciphertext)
    EncryptedAttribute.new(key: new_key).write(plaintext)
  end
end
