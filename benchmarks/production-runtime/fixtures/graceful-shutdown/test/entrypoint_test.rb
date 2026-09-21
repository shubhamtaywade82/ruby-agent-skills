source = File.read(File.expand_path("../bin/entrypoint", __dir__))
abort "must trap TERM" unless source.include?("TERM")
abort "must forward signal" unless source.include?('kill -TERM')
