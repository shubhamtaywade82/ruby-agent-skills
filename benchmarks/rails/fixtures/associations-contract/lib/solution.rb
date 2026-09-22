# frozen_string_literal: true
class Account
  attr_reader :id,:tenant_id,:projects,:attachments
  def initialize(id:,tenant_id:) = (@id,@tenant_id,@projects,@attachments=id,tenant_id,[],[])
  def add_project(project) = @projects << project
  def attach(file) = @attachments << file
end
class Membership
  attr_reader :account,:project,:state
  def initialize(account:,project:,state:) = (@account,@project,@state=account,project,state)
end
class AttachmentTarget
  ALLOWED_TYPES=%w[Account Project].freeze
  def initialize(type:) = raise ArgumentError unless ALLOWED_TYPES.include?(type)
end
class AssociationContract
  def initialize(account:) = @account=account
  def each_recent = @account.projects.first(3)
  def autosave!(project) = @account.add_project(project)
end
