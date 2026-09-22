# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/solution"

class RouteSetTest < Minitest::Test
  def setup
    @routes = RouteSet.new
    @routes.get("/photos/:id", name: :photo, target: "photos#show")
    @routes.get("/photos/poll", name: :poll, target: "photos#poll")
    @routes.get("/admin", name: :admin, target: "admin#index", host: "admin.example.com")
    @routes.get("/*path", name: :frontend, target: "spa#show")
  end

  def test_literal_route_wins_over_dynamic_member_route
    assert_equal :poll, @routes.recognize("/photos/poll")[:name]
  end

  def test_host_constraint_is_not_authorization
    assert_equal :admin, @routes.recognize("/admin", host: "admin.example.com")[:name]
    assert_nil @routes.recognize("/admin", host: "www.example.com")
  end

  def test_helpers_generate_stable_urls
    assert_equal "/photos/42", @routes.url_for(:photo, id: 42)
  end

  def test_catch_all_only_handles_the_unmatched_surface
    assert_equal :frontend, @routes.recognize("/unknown")[:name]
  end
end
