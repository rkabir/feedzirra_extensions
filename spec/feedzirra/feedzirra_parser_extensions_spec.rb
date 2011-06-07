require 'spec_helper'

describe Feedzirra::FeedzirraParserExtensions do
  #before (:each) do
    #@class = Class.new do
    #  include Feedzirra::FeedzirraParserExtensions
    #end
  #end
  # @feed = Feedzirra::Feed.parse(sample_atom_feed)
  it "should include the extensions in parsed feeds" do
    atom = Feedzirra::Feed.parse(sample_atom_feed)
    itunes = Feedzirra::Feed.parse(sample_itunes_feed)
    rdf = Feedzirra::Feed.parse(sample_rdf_feed)
    rss = Feedzirra::Feed.parse(sample_rss_feed)
    rss_feedburner = Feedzirra::Feed.parse(sample_rss_feed_burner_feed)
    atom_feedburner = Feedzirra::Feed.parse(sample_feedburner_atom_feed)
    wfw = Feedzirra::Feed.parse(sample_wfw_feed)
    
    feeds = [atom, itunes, rdf, rss, rss_feedburner, atom_feedburner, wfw]
    feeds.each do |f|
      f.class.include?(Feedzirra::FeedzirraParserExtensions).should be_true
    end
  end
  
  describe "filtering by title" do
    before (:each) do
      @atom = Feedzirra::Feed.parse(sample_atom_feed)
    end
    
    it "should have phrase in title" do
      filtered = @atom.match_title("cloud computing")
      filtered.size.should == 1
    end
    it "should have any word in title" do
      filtered = @atom.match_title_any_word("mainframe job")
      filtered.size.should == 2
    end
    it "should have all words in title" do
      filtered = @atom.match_title_all_words("mainframe cloud")
      filtered.size.should == 1
    end
  end
  pending "should filter by author"
  pending "should filter by keyword"
  pending "should filter by text"
  pending "should filter by images"
  pending "should filter by links"
  pending "should filter randomly"
  
  describe "calling the correct methods when using where and arguments" do
  end
  describe "calling the correct methods when using where_not and arguments" do
  end
end
