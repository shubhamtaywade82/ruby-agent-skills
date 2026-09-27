# frozen_string_literal: true

class Account
  attr_reader :id, :tenant_id, :projects, :attachments

  def initialize(id:, tenant_id:)
    @id = id
    @tenant_id = tenant_id
    @projects = []
    @attachments = []
  end

  def add_project(project)
    @projects << project
  end

  def attach(file)
    @attachments << file
  end
end

# Explicit join model: the relationship carries its own state.
class Membership
  attr_reader :account, :project, :state

  def initialize(account:, project:, state:)
    @account = account
    @project = project
    @state = state
  end
end

class AttachmentTarget
  ALLOWED_TYPES = %w[Account Project].freeze

  attr_reader :type

  # Client-supplied polymorphic type names are checked against an explicit
  # allowlist and never constantized.
  def initialize(type:)
    raise ArgumentError, "unsupported attachment target: #{type}" unless ALLOWED_TYPES.include?(type)

    @type = type
  end
end

class AssociationContract
  RECENT_LIMIT = 3

  def initialize(account:)
    @account = account
  end

  # Bounded traversal of the collection instead of loading the whole graph.
  def each_recent
    @account.projects.last(RECENT_LIMIT)
  end

  # Parent-owned persistence of a child, mirroring autosave on the association.
  def autosave!(project)
    @account.add_project(project)
  end
end
