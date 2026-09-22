# frozen_string_literal: true
class DocumentAttachment
  MAX_BYTES = 5_000_000
  def initialize(account:,allowed_types:) = (@account,@allowed_types=account,allowed_types)
  def authorize!(tenant_id:) = raise "forbidden" unless @account[:tenant_id]==tenant_id
  def attach(file:,tenant_id:)
    authorize!(tenant_id:)
    raise "invalid upload" unless @allowed_types.include?(file[:content_type]) && file[:bytes] <= MAX_BYTES
    @account[:attachment]={key:file[:key],content_type:file[:content_type]}
  end
  def purge_later = {job:"ActiveStorage::PurgeJob",account_id:@account[:id]}
  def serve(tenant_id:)
    authorize!(tenant_id:)
    @account[:attachment]
  end
end
