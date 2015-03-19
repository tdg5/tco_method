require "bundler/gem_tasks"
require "rake/testtask"
require "rake/extensiontask"

Rake::TestTask.new do |t|
  t.libs << "test"
  t.pattern = "test/**/*_test.rb"
end

Rake::ExtensionTask.new("tco_method") do |ext|
  ext.lib_dir = "lib/tco_method"
end

task :default => :test

Rake::Task[:test].prerequisites << :compile
