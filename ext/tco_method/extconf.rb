require "debase/ruby_core_source"

unless ARGV.any? {|arg| arg.include?('--with-ruby-include') }
  require 'rbconfig'
  bindir = RbConfig::CONFIG['bindir']
  if bindir =~ %r{(^.*/\.rbenv/versions)/([^/]+)/bin$}
    ruby_include = "#{$1}/#{$2}/include/ruby-1.9.1/ruby-#{$2}"
    ARGV << "--with-ruby-include=#{ruby_include}"
  elsif bindir =~ %r{(^.*/\.rvm/rubies)/([^/]+)/bin$}
    ruby_include = "#{$1}/#{$2}/include/ruby-1.9.1/#{$2}"
    ruby_include = "#{ENV['rvm_path']}/src/#{$2}" unless File.exist?(ruby_include)
    ARGV << "--with-ruby-include=#{ruby_include}"
  end
  puts "Using ruby source from #{ruby_include}"
end

require "mkmf"

hdrs = proc { have_header("vm_core.h") }

dir_config("ruby")
if !Debase::RubyCoreSource::create_makefile_with_core(hdrs, "tco_method/tco_method")
  STDERR.print("Makefile creation failed\n")
  STDERR.print("*************************************************************\n\n")
  STDERR.print("  NOTE: If your headers were not found, try passing\n")
  STDERR.print("        --with-ruby-include=PATH_TO_HEADERS      \n\n")
  STDERR.print("*************************************************************\n\n")
  exit(1)
end
