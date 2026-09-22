source = File.read(File.expand_path("../test/system/checkout_test.rb", __dir__))
abort "missing system test base" unless source.include?("ApplicationSystemTestCase")
abort "missing user interaction" unless source.include?("click_on")
abort "missing user-visible assertion" unless source.include?("assert_text")
