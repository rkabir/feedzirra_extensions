require 'feedzirra'
require 'nokogiri'

module Feedzirra
  module FeedzirraParserExtensions
    # mix this into feed, or whatever else has an entries object

    def where_entries(options = {})
      return self if options == {}
      entries = self.entries
      if options['text']
        entries = entries.find_all do |entry|
          (!entry.title.nil? && entry.title.include?(options['string'])) ||
            (!entry.summary.nil? && entry.summary.include?(options['string'])) ||
            (!entry.content.nil? && entry.content.include?(options['string']))
        end
      end
      if options['author']
        entries = entries.find_all do |entry| 
          !entry.author.nil? && entry.author.include?(options['author'])
        end
      end
      if options['has_image']
        entries = entries.find_all do |entry|
          # TODO: What happens if parse fails?
          html = Nokogiri::HTML(entry.content)
          html.search("img").length > 0
        end
      end
      if options['has_attachment']
        entries = entries.send(method) do |entry|
          # TODO
          entry
        end
      end
      return ::Feedzirra::Parser::GenericParser.new(self.title, self.url, entries)
    end
    
    def where_entries_not(options = {})
      return self if options == {}
      entries = self.entries
      if options['text']
        entries = entries.reject do |entry|
          (!entry.title.nil? && entry.title.include?(options['string'])) ||
            (!entry.summary.nil? && entry.summary.include?(options['string'])) ||
            (!entry.content.nil? && entry.content.include?(options['string']))
        end
      end
      if options['author']
        entries = entries.reject do |entry| 
          !entry.author.nil? && entry.author.include?(options['author'])
        end
      end
      if options['has_image']
        entries = entries.reject do |entry|
          # TODO: What happens if parse fails?
          html = Nokogiri::HTML(entry.content)
          html.search("img").length > 0
        end
      end
      if options['has_attachment']
        entries = entries.send(method) do |entry|
          # TODO
          entry
        end
      end
      return ::Feedzirra::Parser::GenericParser.new(self.title, self.url, entries)
    end
    
    def map_entries(options = {})
      return self if options = {}
      entries = self.entries
      if options['images']
        entries = entries.map do |entry| 
          html = Nokogiri::HTML(entry.content)
          html.search("img")
          # TODO: actually build up the document
        end
      end
      if options['attachments']
      end
      if options['audio']
      end
      if options['video']
      end
      return ::Feedzirra::Parser::GenericParser.new(self.title, self.url, entries)
    end
    
    def remove_entries(options = {})
      return self if options = {}
      entries = self.entries
      if options['images']
      end
      if options['attachments']
      end
      if options['audio']
      end
      if options['video']
      end
      return ::Feedzirra::Parser::GenericParser.new(self.title, self.url, entries)
    end

    ###
    ### These old find_all_by/reject_by methods will be deprecated
    ### and it will be more like activerecord, see above.
    ### We could go back and implement method_missing, but that might be ugly
    ### as a mixin with AR
    ###
    def find_all_by_string(options = {})
      entries = self.entries.find_all { |entry|
        # TODO: Should not consider any embedded HTML
        # TODO: Should consider any other attributes you care about
        entry.title.include?(string) || entry.summary.include?(string) ||
          entry.content.include?(string)
      }
      return ::Feedzirra::Parser::GenericParser.new(self.title, self.url, entries)
    end

    def reject_by_string(string)
      entries = self.entries.reject { |entry|
        # TODO: Should not consider any embedded HTML
        # TODO: Should consider any other attributes you care about
        entry.title.include?(string) || entry.summary.include?(string) ||
          entry.content.include?(string)
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
      # I think you have to keep all the individal feeds'
      # etags and last modified times around in a separate
      # data structure and override the methods that check for updates

      # include ::FeedZirra::FeedUtilities
      # include ::FeedZirra::FeedzirraParserExtensions
      include FeedUtilities
      include FeedzirraParserExtensions
      attr_accessor :title, :url, :feed_url, :entries, :etag, :last_modified
      def initialize(title, url, entries)
        self.url = url
        self.title = title
        # ensure this is an Array, or you can't do silly stuff like size()
        self.entries = entries.to_a
      end
    end
  end
end

# Mix in with Feedzirra parsers
# Or if you switch backends from Feedzirra you can mix in appropriately
[
  Feedzirra::Parser::Atom, Feedzirra::Parser::AtomFeedBurner,
  Feedzirra::Parser::ITunesRSS, Feedzirra::Parser::RSS
].each do |klass|
  klass.class_eval do
    include Feedzirra::FeedzirraParserExtensions
  end
end