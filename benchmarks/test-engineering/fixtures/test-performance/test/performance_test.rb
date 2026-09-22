source = File.read(File.expand_path("../test_helper.rb", __dir__))
abort "global helper glob still present" if source.match?(/Dir\[Rails\.root\.join\("test"/)
abort "deep factory graph still present" if source.include?("build_customer_with_all_associations")
abort "test assertions must remain" unless Dir["test/**/*_test.rb"].any? { |path| File.read(path).include?("assert") }
