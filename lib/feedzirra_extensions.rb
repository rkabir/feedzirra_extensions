require 'feedzirra'
require 'nokogiri'
require 'active_support'

module Feedzirra
  module FeedzirraParserExtensions
    # mix this into feed, or whatever else has an entries object

    def match_author(name)
      name = name.downcase || ""
      self.entries.find_all do |entry|
        author = entry.author.downcase || ""
        author.include?(name)
      end
    end

    def cleaned_content(entry)
      title = entry.title ? entry.title.downcase || ""
      summary = entry.summary ? entry.summary.downcase || ""
      content = entry.content ? entry.content.downcase || ""
      return title, summary, content
    end

    def match_exact_string(match_string)
      text = match_string.downcase || ""
      entries.find_all do |entry|
        title, summary, content = cleaned_content(entry)
        title.include?(text) ||
          summary.include?(text) ||
          content.include?(text)
      end
    end

    def match_any_string(token_string)
      tokens = token_string.split
      results = []
      tokens.each do |token|
        results << match_exact_string(token)
      end
      return results.flatten
    end

    def entries_with_images(args)
      entries.find_all do |entry|
        begin
          html = Nokogiri::HTML(entry.content)
        rescue
          return true
        end
        html.search("img").length > 0
      end
    end

    def entries_with_links(args)
      entries.find_all do |entry|
        begin
          html = Nokogiri::HTML(entry.content)
        rescue
          return true
        end
        html.search("a[href]").length > 0
      end
    end

    def where_entries(options = {})
      return self if options == {}
      options = options.with_indifferent_access
      entries = self.entries
      if options['text']
        entries = match_exact_string(options['text'])
      end
      if options['author']
        entries = match_author(name)
      end
      if options['has_image']
        entries = entries_with_images
      end
      if options['has_link']
        entries = entries_with_links
      end
      if options['has_attachment']
        entries = entries.find_all do |entry|
          # TODO
          entry
        end
      end
      return Feedzirra::Parser::GenericParser.new(self.title, self.url, entries)
    end

    def where_entries_not(options = {})
      return self if options == {}
      options = options.with_indifferent_access
      entries = self.entries
      if options['text']
        entries = entries.reject do |entry|
          title = entry.title ? entry.title.downcase : ""
          summary = entry.summary ? entry.summary.downcase : ""
          content = entry.content ? entry.content.downcase : ""
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
      end
      if options['has_attachment']
        entries = entries.send(method) do |entry|
          # TODO
          entry
        end
      end
      return Feedzirra::Parser::GenericParser.new(self.title, self.url, entries)
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
      return Feedzirra::Parser::GenericParser.new(self.title, self.url, entries)
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
      return Feedzirra::Parser::GenericParser.new(self.title, self.url, entries)
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