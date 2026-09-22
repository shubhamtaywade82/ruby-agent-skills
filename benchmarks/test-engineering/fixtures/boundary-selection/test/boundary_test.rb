files = Dir["test/**/*.rb"].map { |path| File.read(path) }
request_test = files.any? { |body| body.include?("ActionDispatch::IntegrationTest") }
controller_direct = files.any? { |body| body.include?("OrdersController") && body.include?("get :") }
abort "missing request integration boundary" unless request_test
abort "direct controller invocation detected" if controller_direct
