# frozen_string_literal: true

class DashboardCache
  VERSION = 1

  # Every identity dimension is part of the key, and ids must be integers so
  # a crafted value cannot shift the ":" boundaries between components.
  def self.key(tenant_id, dashboard_id)
    "dashboard:v#{VERSION}:tenant:#{Integer(tenant_id)}:dashboard:#{Integer(dashboard_id)}"
  end
end
