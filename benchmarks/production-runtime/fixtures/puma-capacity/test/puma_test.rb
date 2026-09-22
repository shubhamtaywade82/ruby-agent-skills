source = File.read(File.expand_path("../config/puma.rb", __dir__))
abort "missing workers" unless source.include?("workers")
abort "missing threads" unless source.include?("threads")
abort "port changed" unless source.include?("PORT")
