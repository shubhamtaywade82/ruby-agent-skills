# frozen_string_literal: true

class DashboardCache
  def self.key(tenant_id, dashboard_id)
    ["dashboard", tenant_id, dashboard_id].join(":")
  end
end
