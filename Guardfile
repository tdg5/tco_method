guard(:minitest, :all_after_pass => false, :all_on_start => false) do
  watch(%r{^lib/tco_method/(.+)\.rb$})                               { |m| "test/unit/#{m[1]}_test.rb" }
  watch(%r{^test/.+_test\.rb$})
  watch(%r{^(?:test/test_helper(.*)|lib/tco_method)\.rb$}) { "test" }
end
