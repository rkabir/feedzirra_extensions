require 'feedzirra'
require 'nokogiri'
require 'active_support'
require 'sanitize'
require 'uri'

module Feedzirra  
  module FeedzirraParserExtensions
    # mix this into feed, or whatever else has an entries object

    ### Method to find base url
    def base_url
      # could use xml:base, but i think that data is lost
      url || feed_url
    end

    def base_url_merge(uri_or_string)
      self.base_url.merge(uri_or_string)
    end
    
    def entries_with_absolute_img_src
      entries.map do |e|
        nodes = Nokogiri::HTML.parse(e.content)
        ge = GenericEntry.create_from_entry(e)
        html.css("img").each do |node|
          node['src'] = base_url_merge(node['src']) if node['src']
        end
        # Might have to mark this as safe on the rails side?
        ge.content = nodes.to_s
        ge
      end
    end

    ###
    ### Methods for where_entries
    ###
    # phrase search, but no word boundary 
    def match_author_exact(name, reject = false)
      name = name.downcase || ""
      proc = Proc.new { |entry|
        author = entry.author.downcase || ""
        author.include?(name)
      }
      reject ? self.entries.reject(&proc) : self.entries.find_all(&proc)
    end

    # phrase search
    def match_title(match_string, reject = false)
      text = match_string.downcase || ""
      re = Regexp.new(/\b#{text}/i)
      proc = Proc.new { |entry|
        clean_title = entry.title ? entry.title.downcase : ""
        !!(clean_title =~ re)
      }
      reject ? self.entries.reject(&proc) : self.entries.find_all(&proc)
    end
    
    # any of the words
    def match_title_any_word(match_string, reject = false)
      text = match_string.downcase || ""
      words = text.split
      res = words.map { |w| Regexp.new(/\b#{w}/i) }
      proc = Proc.new { |entry|
        clean_title = entry.title ? entry.title.downcase : ""
        res.collect { |re|
          !!(clean_title =~ re)
        }.inject(:|)
      }
      reject ? self.entries.reject(&proc) : self.entries.find_all(&proc)
    end
    
    # all of the words
    def match_title_all_words(match_string, reject = false)
      text = match_string.downcase || ""
      words = text.split
      res = words.map { |w| Regexp.new(/\b#{w}/i) }
      proc = Proc.new { |entry|
        clean_title = entry.title ? entry.title.downcase : ""
        res.collect { |re|
          !!(clean_title =~ re)
        }.inject(:&)
      }
      reject ? self.entries.reject(&proc) : self.entries.find_all(&proc)
    end

    # phrase, no word boundary
    def match_text_exact(match_string, reject = false)
      text = match_string.downcase || ""
      proc = Proc.new { |entry|
        title, summary, content = cleaned_content(entry)
        title.include?(text) ||
          summary.include?(text) ||
          content.include?(text)
      }
      reject ? self.entries.reject(&proc) : self.entries.find_all(&proc)
    end

    # phrase
    def match_text(match_string, reject = false)
      text = match_string.downcase || ""
      re = Regexp.new(/\b#{text}/i)
      proc = Proc.new { |entry|
        title, summary, content = cleaned_content(entry)
        !!(title =~ re) ||
          !!(Nokogiri::HTML(summary).content =~ re) ||
          !!(Nokogiri::HTML(content).content =~ re)
      }
      reject ? self.entries.reject(&proc) : self.entries.find_all(&proc)
    end

    # any word
    def match_text_any_word(match_string, reject = false)
      text = match_string.downcase || ""
      words = text.split
      res = words.map { |w| Regexp.new(/\b#{w}/i) }
      proc = Proc.new { |entry|
        title, summary, content = cleaned_content(entry)
        res.collect { |re|
          !!(
            title =~ re ||
            Nokogiri::HTML(summary).content =~ re ||
            Nokogiri::HTML(content).content =~ re
          )
        }.inject(:|)
      }
      reject ? self.entries.reject(&proc) : self.entries.find_all(&proc)
    end
    
    def match_text_all_words(match_string, reject = false)
      text = match_string.downcase || ""
      words = text.split
      res = words.map { |w| Regexp.new(/\b#{w}/i) }
      proc = Proc.new { |entry|
        title, summary, content = cleaned_content(entry)
        res.collect { |re|
          !!(
            title =~ re ||
            Nokogiri::HTML(summary).content =~ re ||
            Nokogiri::HTML(content).content =~ re
          )
        }.inject(:&)
      }
      reject ? self.entries.reject(&proc) : self.entries.find_all(&proc)
    end

    def entries_with_images(reject = false)
      proc = Proc.new { |entry|
        begin
          html = Nokogiri::HTML(entry.content)
        rescue
          return true
        end
        html.search("img").length > 0
      }
      reject ? self.entries.reject(&proc) : self.entries.find_all(&proc)
    end

    def entries_with_links(reject = false)
      proc = Proc.new { |entry|
        begin
          html = Nokogiri::HTML(entry.content)
        rescue
          return true
        end
        html.search("a[href]").length > 0
      }
      reject ? self.entries.reject(&proc) : self.entries.find_all(&proc)
    end

    def entries_randomly(frequency, reject = false)
      frequency = 1 - frequency if reject
      return entries if frequency >= 1
      proc = Proc.new { |entry|
        Random.rand < frequency
      }
    end

    # this is implicitly an AND if you include
    # more than one type of filter
    # right now, though, AND/OR is handled at the top level
    # by combining the results
    def where_entries(options = {})
      return self if options == {}
      options = options.with_indifferent_access
      entries = self.entries
      if options['title']
        entries = match_title(options['title'])
      end
      if options['title_any']
        entries = match_title(options['title_any'])
      end
      if options['title_all']
        entries = match_title(options['title_all'])
      end
      if options['text']
        entries = match_text(options['text'])
      end
      if options['text_any']
        entries = match_text_any_word(options['text_any'])
      end
      if options['text_all']
        entries = match_text_all_words(options['text_all'])
      end
      if options['author']
        entries = match_author_exact(options['author'])
      end
      if options['has_image']
        entries = entries_with_images
      end
      if options['has_link']
        entries = entries_with_links
      end
      if options['has_attachment']
        entries
      end
      if options['random']
        entries = entries_randomly(options['random'])
      end
      return Feedzirra::Parser::GenericParser.new(self.title, self.url, entries)
    end

    ###
    ### Methods for where_entries_not
    ###

    def where_entries_not(options = {})
      return self if options == {}
      options = options.with_indifferent_access
      entries = self.entries
      if options['title']
        entries = match_title(options['title'], true)
      end
      if options['title_any']
        entries = match_title(options['title_any'], true)
      end
      if options['title_all']
        entries = match_title(options['title_all'], true)
      end
      if options['text']
        entries = match_text(options['text'], true)
      end
      if options['text_any']
        entries = match_text_any_word(options['text_any'], true)
      end
      if options['text_all']
        entries = match_text_all_words(options['text_all'], true)
      end
      if options['author']
        entries = match_author_exact(options['author'], true)
      end
      if options['has_image']
        entries = entries_with_images(true)
      end
      if options['has_link']
        entries = entries_with_links(true)
      end
      if options['has_attachment']
        entries
      end
      if options['random']
        entries = entries_randomly(options['random'], true)
      end
      return Feedzirra::Parser::GenericParser.new(self.title, self.url, entries)
    end

    def map_entries(options = {})
      return self if options = {}
      options = options.with_indifferent_access
      entries = self.entries
      if options['images']
        entries = entries.map do |entry|
          title, summary, content = cleaned_content(entry)
          ge = GenericEntry.create_from_entry(entry)
          ge.content = Sanitize.clean(content, :elements => ['img'])
          ge
        end
      end
      if options['links']
        entries = entries.map do |entry|
          title, summary, content = cleaned_content(entry)
          ge = GenericEntry.create_from_entry(entry)
          ge.content = Sanitize.clean(content, :elements => ['a'])
          ge
        end
      end
      if options['attachments']
        # TODO
      end
      if options['audio']
        # TODO
      end
      if options['video']
        # TODO
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
    
    ### Private methods
    
    private
    def cleaned_content(entry)
      title = entry.title ? entry.title.downcase : ""
      summary = entry.summary ? entry.summary.downcase : ""
      content = entry.content ? entry.content.downcase : ""
      return title, summary, content
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
      PARSER_ATTRIBUTES = [:title, :url, :feed_url, :entries, :etag, 
        :last_modified]
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
    
    class GenericEntry
      INSTANCE_VARIABLES = ["@title", "@name", "@content", "@url", "@author",
        "@summary", "@published", "@entry_id", "@updated", "@categories",
        "@links"]
      include FeedEntryUtilities
      attr_accessor :title, :name, :content, :url, :author, :summary,
        :published, :entry_id, :updated, :categories, :links
      def self.create_from_entry(entry)
        ge = GenericEntry.new
        entry.instance_variables.each do |iv|
          # only set attributes GenericEntries have.
          if INSTANCE_VARIABLES.include?(iv)
            value = entry.instance_variable_get(iv)
            ge.instance_variable_set(iv, value)
          end
        end
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