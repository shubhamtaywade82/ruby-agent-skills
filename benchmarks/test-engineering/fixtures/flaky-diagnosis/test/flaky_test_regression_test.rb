files = Dir["test/**/*.rb"].map { |path| [path, File.read(path)] }
bodies = files.map(&:last).join("\n")
abort "sleep workaround detected" if bodies.match?(/\bsleep\s*\(/)
abort "retry workaround detected" if bodies.match?(/retry\s+if|rescue.*retry/m)
abort "shared mutable global detected" if bodies.match?(/^\$\w+\s*=/)
abort "missing order-independent test marker" unless files.any? { |path, body| path.end_with?("order_test.rb") && body.include?("ShippingContext") }
