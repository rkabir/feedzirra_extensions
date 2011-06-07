require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rspec'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'feedzirra_extensions'

# gem install redgreen for colored test output
# begin require "redgreen" unless ENV['TM_CURRENT_LINE']; rescue LoadError; end

RSpec.configure do |config|
  config.mock_with :rspec
end

def load_sample(filename)
  File.read("#{File.dirname(__FILE__)}/sample_feeds/#{filename}")
end

def sample_atom_feed
  load_sample("AmazonWebServicesBlog.xml")
end

def sample_atom_entry_content
  load_sample("AmazonWebServicesBlogFirstEntryContent.xml")
end

def sample_itunes_feed
  load_sample("itunes.xml")
end

def sample_rdf_feed
  load_sample("HREFConsideredHarmful.xml")
end

def sample_rdf_entry_content
  load_sample("HREFConsideredHarmfulFirstEntry.xml")
end

def sample_rss_feed_burner_feed
  load_sample("SamHarrisAuthorPhilosopherEssayistAtheist.xml")
end

def sample_rss_feed
  load_sample("TenderLovemaking.xml")
end

def sample_rss_entry_content
  load_sample("TenderLovemakingFirstEntry.xml")
end

def sample_feedburner_atom_feed
  load_sample("PaulDixExplainsNothing.xml")
end

def sample_feedburner_atom_entry_content
  load_sample("PaulDixExplainsNothingFirstEntryContent.xml")
end

def sample_wfw_feed
  load_sample("PaulDixExplainsNothingWFW.xml")
end

def multiple_author_feed
  load_sample("Engadget.xml")
end

# only needed if testing time?
# class Time
#   def to_s
#     strftime("%a %b %d %H:%M:%S %Z %Y")
#   end
# end