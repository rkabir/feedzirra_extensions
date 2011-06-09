# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{feedzirra_extensions}
  s.version = "0.2.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Alvin Liang", "Ryan Kabir"]
  s.date = %q{2011-06-09}
  s.description = %q{No really, extensions to Feedzirra}
  s.email = %q{ayliang@gmail.com}
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README",
    "README.rdoc"
  ]
  s.files = [
    ".document",
    ".rspec",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE.txt",
    "README",
    "README.rdoc",
    "Rakefile",
    "VERSION",
    "feedzirra_extensions.gemspec",
    "lib/feedzirra_extensions.rb",
    "spec/feedzirra/feedzirra_parser_extensions_spec.rb",
    "spec/sample_feeds/AmazonWebServicesBlog.xml",
    "spec/sample_feeds/AmazonWebServicesBlogFirstEntryContent.xml",
    "spec/sample_feeds/Engadget.xml",
    "spec/sample_feeds/HREFConsideredHarmful.xml",
    "spec/sample_feeds/HREFConsideredHarmfulFirstEntry.xml",
    "spec/sample_feeds/PaulDixExplainsNothing.xml",
    "spec/sample_feeds/PaulDixExplainsNothingAlternate.xml",
    "spec/sample_feeds/PaulDixExplainsNothingFirstEntryContent.xml",
    "spec/sample_feeds/PaulDixExplainsNothingWFW.xml",
    "spec/sample_feeds/SamHarrisAuthorPhilosopherEssayistAtheist.xml",
    "spec/sample_feeds/TenderLovemaking.xml",
    "spec/sample_feeds/TenderLovemakingFirstEntry.xml",
    "spec/sample_feeds/TrotterCashionHome.xml",
    "spec/sample_feeds/atom_with_link_tag_for_url_unmarked.xml",
    "spec/sample_feeds/itunes.xml",
    "spec/sample_feeds/run_against_sample.rb",
    "spec/sample_feeds/top5kfeeds.dat",
    "spec/sample_feeds/trouble_feeds.txt",
    "spec/spec_helper.rb"
  ]
  s.homepage = %q{http://github.com/rkabir/feedzirra_extensions}
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{Extensions to Feedzirra}
  s.test_files = [
    "spec/feedzirra/feedzirra_parser_extensions_spec.rb",
    "spec/sample_feeds/run_against_sample.rb",
    "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<feedzirra>, [">= 0"])
      s.add_runtime_dependency(%q<i18n>, [">= 0"])
      s.add_runtime_dependency(%q<nokogiri>, [">= 0"])
      s.add_runtime_dependency(%q<sanitize>, [">= 0"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.5.2"])
      s.add_development_dependency(%q<rcov>, [">= 0"])
      s.add_development_dependency(%q<rspec>, [">= 0"])
      s.add_runtime_dependency(%q<feedzirra>, [">= 0"])
      s.add_runtime_dependency(%q<nokogiri>, [">= 0"])
      s.add_runtime_dependency(%q<activesupport>, [">= 0"])
      s.add_runtime_dependency(%q<sanitize>, [">= 0"])
      s.add_runtime_dependency(%q<ruby-readability>, [">= 0"])
      s.add_development_dependency(%q<rspec>, [">= 0"])
    else
      s.add_dependency(%q<feedzirra>, [">= 0"])
      s.add_dependency(%q<i18n>, [">= 0"])
      s.add_dependency(%q<nokogiri>, [">= 0"])
      s.add_dependency(%q<sanitize>, [">= 0"])
      s.add_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_dependency(%q<jeweler>, ["~> 1.5.2"])
      s.add_dependency(%q<rcov>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 0"])
      s.add_dependency(%q<feedzirra>, [">= 0"])
      s.add_dependency(%q<nokogiri>, [">= 0"])
      s.add_dependency(%q<activesupport>, [">= 0"])
      s.add_dependency(%q<sanitize>, [">= 0"])
      s.add_dependency(%q<ruby-readability>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 0"])
    end
  else
    s.add_dependency(%q<feedzirra>, [">= 0"])
    s.add_dependency(%q<i18n>, [">= 0"])
    s.add_dependency(%q<nokogiri>, [">= 0"])
    s.add_dependency(%q<sanitize>, [">= 0"])
    s.add_dependency(%q<bundler>, ["~> 1.0.0"])
    s.add_dependency(%q<jeweler>, ["~> 1.5.2"])
    s.add_dependency(%q<rcov>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 0"])
    s.add_dependency(%q<feedzirra>, [">= 0"])
    s.add_dependency(%q<nokogiri>, [">= 0"])
    s.add_dependency(%q<activesupport>, [">= 0"])
    s.add_dependency(%q<sanitize>, [">= 0"])
    s.add_dependency(%q<ruby-readability>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 0"])
  end
end

