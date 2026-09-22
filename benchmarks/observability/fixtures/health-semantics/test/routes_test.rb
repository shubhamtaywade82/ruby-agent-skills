source = File.read(File.expand_path("../config/routes.rb", __dir__))
abort "missing built-in health route" unless source.include?('rails/health#show')
abort "liveness must not probe all dependencies" if source.match?(/Redis|redis|ExternalService|Database\.connection/)
