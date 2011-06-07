require 'spec_helper'

describe Feedzirra::FeedzirraParserExtensions do
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
    before (:all) do
      # careful not to modify this
      @atom = Feedzirra::Feed.parse(sample_atom_feed)
    end
    
    it "should have phrase in title" do
      filtered = @atom.match_title("cloud computing")
      filtered.size.should == 1
      filtered.entries.first.title.should == "Cloud Computing and Biomedical Research Roundtable in San Diego"
    end
    it "should have any word in title" do
      filtered = @atom.match_title_any_word("mainframe job")
      filtered.size.should == 2
      # note that the html entity is converted
      filtered.entries.first.title.should == "AWS Job: Architect & Designer Position in Turkey"
      filtered.entries.last.title.should == "Mainframes in the Cloud?"
    end
    it "should have all words in title" do
      filtered = @atom.match_title_all_words("mainframe cloud")
      filtered.size.should == 1
      filtered.entries.first.title.should == "Mainframes in the Cloud?"
    end
  end
  
  describe "filtering by author" do
    before (:all) do
      @rss = Feedzirra::Feed.parse(multiple_author_feed)
    end
    
    it "should match author exactly" do
      filtered = @rss.match_author_exact("jacob schulman")
      filtered.size.should == 2
      filtered.entries.first.author.should == "Jacob Schulman"
    end
  end

  describe "filtering by keyword" do
    pending "should match one keyword exactly"
    pending "should have one word in any keyword"
    pending "should have all words in any keyword"
    pending "should fall back to text"
  end
  pending "should filter by text"
  pending "should filter by images"
  pending "should filter by links"
  pending "should filter randomly"
  
  describe "calling the correct methods when using where and arguments" do
  end
  describe "calling the correct methods when using where_not and arguments" do
  end
end
