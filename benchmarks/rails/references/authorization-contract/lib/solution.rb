# frozen_string_literal: true

class DocumentPolicy
  def initialize(actor)
    @actor = actor
  end

  # Tenant membership is a precondition for every role, including admin.
  def read?(document)
    return false unless document[:tenant_id] == @actor[:tenant_id]

    @actor[:role] == :admin || @actor[:id] == document[:owner_id]
  end

  # Collection scope: the tenant predicate is applied before enumeration.
  def scope(documents)
    tenant_documents = documents.select { |document| document[:tenant_id] == @actor[:tenant_id] }
    tenant_documents.select { |document| read?(document) }
  end
end

class DocumentService
  def initialize(documents:)
    @documents = documents
  end

  def fetch(id:, actor:)
    document = DocumentPolicy.new(actor).scope(@documents).detect { |candidate| candidate[:id] == id }
    authorize!(document, actor)
    document
  end

  def list(actor:)
    DocumentPolicy.new(actor).scope(@documents)
  end

  private

  # Missing and forbidden look the same, so ids in other tenants are not disclosed.
  def authorize!(document, actor)
    raise "forbidden" unless document && DocumentPolicy.new(actor).read?(document)

    true
  end
end
