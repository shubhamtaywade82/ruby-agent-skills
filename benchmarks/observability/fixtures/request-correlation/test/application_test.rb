source = File.read(File.expand_path("../config/application.rb", __dir__))
abort "must reuse request id" unless source.match?(/request\.uuid|request_id|request\.request_id/)
abort "must filter authorization" unless source.match?(/Authorization|authorization/)
