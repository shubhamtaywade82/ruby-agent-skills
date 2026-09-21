source = File.read(File.expand_path("../test_helper.rb", __dir__))
abort "global shared mutable array detected" if source.match?(/^\w+_STATE\s*=\s*\[\]/)
abort "hard-coded shared port detected" if source.match?(/^TEST_PORT\s*=\s*3000$/)
abort "parallelization was globally removed" unless source.include?("parallelize")
