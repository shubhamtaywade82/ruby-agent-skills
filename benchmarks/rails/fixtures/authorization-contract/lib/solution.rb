# frozen_string_literal: true

class DocumentPolicy
  def initialize(actor)
    @actor = actor
  end

  def read?(document)
    @actor[:role] == :admin || @actor[:id] == document[:owner_id]
  end
end

class DocumentService
  def initialize(documents:)
    @documents = documents
  end

  def fetch(id:, actor:)
    document = @documents.find { |candidate| candidate[:id] == id }
    authorize!(document, actor)
    document
  end

  def list(actor:)
    @documents.select { |document| DocumentPolicy.new(actor).read?(document) }
  end

  private

  def authorize!(document, actor)
    raise "forbidden" unless document && DocumentPolicy.new(actor).read?(document)

    true
  end
end
