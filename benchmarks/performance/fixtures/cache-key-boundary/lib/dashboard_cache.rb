# frozen_string_literal: true

class DashboardCache
  def self.key(tenant_id, dashboard_id)
    ["dashboard", dashboard_id].join(":")
  end
end
