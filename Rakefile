require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "feedzirra_extensions"
  gem.homepage = "http://github.com/rkabir/feedzirra_extensions"
  gem.license = "MIT"
  gem.summary = "Extensions to Feedzirra"
  gem.description = "No really, extensions to Feedzirra"
  gem.email = "ayliang@gmail.com"
  gem.authors = ["Alvin Liang", "Ryan Kabir"]
  # Include your dependencies below. Runtime dependencies are required when using your gem,
  # and development dependencies are only needed for development (ie running rake tasks, tests, etc)
  gem.add_dependency 'feedzirra'
  gem.add_dependency 'nokogiri'
  gem.add_dependency 'activesupport'
  gem.add_dependency 'sanitize'
  gem.add_dependency 'ruby-readability'
  gem.add_development_dependency 'rspec'
  #  gem.add_runtime_dependency 'jabber4r', '> 0.1'
  #  gem.add_development_dependency 'rspec', '> 1.2.3'
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |test|
  test.pattern = 'spec/**/*_spec.rb'
  # test.verbose = true
end

require 'rcov/rcovtask'
Rcov::RcovTask.new do |test|
  test.pattern = 'spec/**/*_spec.rb'
  test.verbose = true
end

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "feedzirra_extensions #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
