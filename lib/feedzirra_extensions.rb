require 'feedzirra'
require 'nokogiri'

# TODO: better namespacing

module Feedzirra
  module FeedzirraParserExtensions
    # mix this into feed, or whatever else has an entries object

    def find_all_by_string(string)
      entries = self.entries.find_all { |entry|
        # TODO: Should not consider any embedded HTML
        # TODO: Should consider any other attributes you care about
        entry.title.include?(string) || entry.content.include?(string)
      }
      return ::Feedzirra::Parser::GenericParser.new(self.title, self.url, entries)
    end

    def reject_by_string(string)
      entries = self.entries.reject { |entry|
        # TODO: Should not consider any embedded HTML
        # TODO: Should consider any other attributes you care about
        entry.title.include?(string) || entry.content.include?(string)
      }
      return ::Feedzirra::Parser::GenericParser.new(self.title, self.url, entries)
    end

    def find_all_by_author(author_name)
      entries = self.entries.find_all { |entry| 
        entry.author.include?(author_name)
      }
      return ::Feedzirra::Parser::GenericParser.new(self.title, self.url, entries)
    end

    def reject_by_author(author_name)
      entries = self.entries.reject { |entry|
        entry.author.include?(author_name)
      }
      return ::Feedzirra::Parser::GenericParser.new(self.title, self.url, entries)
    end

    def find_all_with_image
      puts "leave only entries with images"
      # parse as HTML using Nokogiri, then see if there are any img tags.
    end

    def reject_with_image
      puts "remove entries with images"
      # parse as HTML using Nokogiri, then see if there are any img tags.
    end

    def map_to_images
      puts "map this feed to images"
      # call find_all_with_image, then strip everything but the images
    end

    def to_rss
      # TODO: Need to implement conversion back to RSS XML
      # Convert the feed back to RSS so you can use it elsewhere?
      # Ideally you'd cache this so maybe this should be at the Rails level
      # Probably want to use a templating language here
    end
  end
  
  class MergedFeed
    def self.fetch_and_parse(title, url, *feed_urls)
      # Create a new feed parser instance from the given feeds,
      # using your title and url
      feeds = ::Feedzirra::Feed.fetch_and_parse(feed_urls)
      entries = []
      feeds.each_pair do |k,v|
        # Brace against response errors
        next if v.is_a?(Fixnum)
        entries = entries + v.entries
      end
      # Sort by date published
      entries.sort! { |x,y| y.published <=> x.published }
      return ::Feedzirra::Parser::GenericParser.new(title, url, entries)
    end
  end

  module Parser
    class GenericParser
      # Not really a parser, just an object that looks like a
      # Feedzirra::Parser::XX object

      # TODO: what about etags, last modified, etc?
      # TODO: if it's filtered, then checking for updates will be different
      # include ::FeedZirra::FeedUtilities
      # include ::FeedZirra::FeedzirraParserExtensions
      include FeedUtilities
      include FeedzirraParserExtensions
      attr_accessor :url, :title, :entries
      def initialize(title, url, entries)
        self.url = url
        self.title = title
        self.entries = entries
      end
    end
  end
end

# You would do this for any other feed parser you implement
# Or if you switch backends from Feedzirra you can mix in appropriately
[
  Feedzirra::Parser::Atom, Feedzirra::Parser::AtomFeedBurner,
  Feedzirra::Parser::ITunesRSS, Feedzirra::Parser::RSS
].each do |klass|
  klass.class_eval do
    include Feedzirra::FeedzirraParserExtensions
  end
end