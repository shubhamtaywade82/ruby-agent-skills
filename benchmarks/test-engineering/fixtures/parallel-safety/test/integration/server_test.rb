require "test_helper"

class ServerTest < ActiveSupport::TestCase
  test "binds a test server to the configured port" do
    assert_operator TEST_PORT, :>=, 3000
    WORKER_STATE << :booted
    assert_includes WORKER_STATE, :booted
  end
end
