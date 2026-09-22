# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/dashboard_cache"

class DashboardCacheTest < Minitest::Test
  def test_key_is_stable
    assert_equal DashboardCache.key(1, 9), DashboardCache.key(1, 9)
  end

  def test_tenants_do_not_collide
    refute_equal DashboardCache.key(1, 9), DashboardCache.key(2, 9)
  end
end
