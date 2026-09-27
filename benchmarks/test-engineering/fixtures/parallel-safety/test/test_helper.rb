class ActiveSupport::TestCase
  parallelize(workers: :number_of_processors)
end

TEST_PORT = 3000
WORKER_STATE = []
