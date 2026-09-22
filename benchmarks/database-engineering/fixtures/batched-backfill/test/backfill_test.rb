source = File.read(File.expand_path("../lib/backfill_normalized_email.rb", __dir__))
abort "missing in_batches" unless source.include?("in_batches")
abort "must be bounded" unless source.match?(/BATCH_SIZE\s*=\s*\d+/)
abort "must not use unbounded each" if source.match?(/User\.all\.each/)
