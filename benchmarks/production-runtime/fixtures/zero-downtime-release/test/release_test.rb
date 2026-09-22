source = File.read(File.expand_path("../docs/release.md", __dir__))
abort "missing expand first" unless source.index("Expand schema") < source.index("Deploy code")
abort "missing readiness gate" unless source.include?("Verify readiness")
abort "contract must be later" unless source.index("Contract") > source.index("Backfill")
