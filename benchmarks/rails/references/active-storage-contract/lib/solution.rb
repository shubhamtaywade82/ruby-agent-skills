# frozen_string_literal: true

class DocumentAttachment
  MAX_BYTES = 5_000_000

  def initialize(account:, allowed_types:)
    @account = account
    @allowed_types = allowed_types
  end

  # The blob key is an object reference, not authorization: every access
  # re-checks the owning account's tenant.
  def authorize!(tenant_id:)
    raise "forbidden" unless @account[:tenant_id] == tenant_id

    true
  end

  def attach(file:, tenant_id:)
    authorize!(tenant_id: tenant_id)
    raise "invalid upload" unless @allowed_types.include?(file[:content_type])
    raise "invalid upload" unless file[:bytes].is_a?(Integer) && file[:bytes].between?(1, MAX_BYTES)

    @account[:attachment] = { key: file[:key], content_type: file[:content_type] }
  end

  # Physical object deletion is asynchronous and separate from detaching.
  def purge_later
    { job: "ActiveStorage::PurgeJob", account_id: @account[:id] }
  end

  def serve(tenant_id:)
    authorize!(tenant_id: tenant_id)
    @account[:attachment]
  end
end
