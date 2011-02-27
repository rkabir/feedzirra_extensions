require 'feedzirra'
require 'nokogiri'
require 'activesupport'

module Feedzirra
  module FeedzirraParserExtensions
    # mix this into feed, or whatever else has an entries object

    def where_entries(options = {})
      return self if options == {}
      options = options.with_indifferent_access
      entries = self.entries
      if options['text']
        entries = entries.find_all do |entry|
          title = entry.title.downcase || ""
          summary = entry.summary.downcase || ""
          content = entry.content.downcase || ""
          text = options['text'].downcase || ""
          title.include?(text) ||
            summary.include?(text) ||
            content.include?(text)
        end
      end
      if options['author']
        entries = entries.find_all do |entry|
          author = entry.author.downcase || ""
          text = options['author'].downcase || ""
          author.include?(text)
        end
      end
      if options['has_image']
        entries = entries.find_all do |entry|
          begin
            html = Nokogiri::HTML(entry.content)
          rescue
            return true
          end
          html.search("img").length > 0
        end
      end
      if options['has_link']
        entries = entries.find_all do |entry|
          begin
            html = Nokogiri::HTML(entry.content)
          rescue
            return true
          end
          links = html.search("a[href]").length > 0
        end
      end
      if options['has_attachment']
        entries = entries.find_all do |entry|
          # TODO
          entry
        end
      end
      return ::Feedzirra::Parser::GenericParser.new(self.title, self.url, entries)
    end

    def where_entries_not(options = {})
      return self if options == {}
      options = options.with_indifferent_access
      entries = self.entries
      if options['text']
        entries = entries.reject do |entry|
          entries = entries.find_all do |entry|
            title = entry.title.downcase || ""
            summary = entry.summary.downcase || ""
            content = entry.content.downcase || ""
            text = options['text'].downcase || ""
            title.include?(text) ||
              summary.include?(text) ||
              content.include?(text)
        end
      end
      if options['author']
        entries = entries.reject do |entry|
          author = entry.author.downcase || ""
          text = options['author'].downcase || ""
          author.include?(text)
        end
      end
      if options['has_image']
        entries = entries.reject do |entry|
          begin
            html = Nokogiri::HTML(entry.content)
          rescue
            return true
          end
          html.search("img").length > 0
        end
      end
      if options['has_link']
        entries = entries.reject do |entry|
          entries = entries.reject do |entry|
            begin
              html = Nokogiri::HTML(entry.content)
            rescue
              return true
            end
            links = html.search("a[href]").length > 0
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
      options = options.with_indifferent_access
      entries = self.entries
      if options['images']
        entries = entries.map do |entry|
          html = Nokogiri::HTML(entry.content)
          html.search("img")
          # TODO: actually build up the document
          # new_entry = ?? Not sure which object
        end
      end
      if options['links']
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
      options = options.with_indifferent_access
      entries = self.entries
      if options['images']
      end
      if options['links']
      end
      if options['attachments']
      end
      if options['audio']
      end
      if options['video']
      end
      return ::Feedzirra::Parser::GenericParser.new(self.title, self.url, entries)
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