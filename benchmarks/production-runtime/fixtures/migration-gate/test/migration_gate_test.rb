source = File.read(File.expand_path("../docs/release-migrations.md", __dir__))
abort "missing rollback limitation" unless source.include?("application rollback restores database")
abort "missing readiness" unless source.include?("Verify readiness")
