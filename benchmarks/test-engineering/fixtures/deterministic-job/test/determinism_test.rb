files = Dir["test/jobs/**/*_test.rb"].map { |path| File.read(path) }.join("\n")
abort "sleep detected" if files.match?(/\bsleep\s*\(/)
abort "direct perform-only test" if files.match?(/\.new\(.*\)\.perform/m) && !files.include?("perform_enqueued_jobs")
abort "missing ActiveJob test helper" unless files.include?("ActiveJob::TestHelper")
