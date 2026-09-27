class ActiveSupport::TestCase
  parallelize(workers: :number_of_processors)
end

TEST_PORT = 3000 + (ENV.fetch("TEST_ENV_NUMBER", "").to_s.hash.abs % 1000)
WORKER_STATE = Thread.current[:worker_state] ||= []
