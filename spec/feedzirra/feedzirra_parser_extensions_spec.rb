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

  describe "filtering by category" do
    before (:all) do
      @rss = Feedzirra::Feed.parse(multiple_author_feed)
      @no_keywords = Feedzirra::Feed.parse(sample_rdf_feed)
    end
    it "should match one category exactly" do
      filtered = @rss.match_categories_exact("home screen")
      filtered.size.should == 1
    end
    it "should match as phrase in any category" do
      # Use 3-word category
      filtered = @rss.match_categories("combat evolved")
      filtered.size.should == 1
    end
    it "should have one word in any category" do
      filtered = @rss.match_categories_any_word("screen")
      filtered.size.should == 3
    end
    it "should have all words in any category" do
      filtered = @rss.match_categories_all_words("screen home")
      filtered.size.should == 1
    end
    it "should fall back to substring in text when matching exactly" do
      filtered = @no_keywords.match_categories_exact("plies the lessons from Small")
      @no_keywords.entries.each do |entry|
        entry.categories.size.should == 0
      end
      filtered.size.should == 1
    end
    it "should fall back to phrase in text when matching phrase in category" do
      filtered = @no_keywords.match_categories("applies the lessons from Smalltalk")
      @no_keywords.entries.each do |entry|
        entry.categories.size.should == 0
      end
      filtered.size.should == 1
    end
    it "should fall back to one word in text when matching one word in category" do
      filtered = @no_keywords.match_categories_any_word("rabbit smalltalk")
      @no_keywords.entries.each do |entry|
        entry.categories.size.should == 0
      end
      filtered.size.should == 6
    end
    it "should fall back to all words in text when matching all words in category" do
      filtered = @no_keywords.match_categories_all_words("lars javascript smalltalk")
      @no_keywords.entries.each do |entry|
        entry.categories.size.should == 0
      end
      filtered.size.should == 1
    end
  end
  
  describe "filtering by text" do
    before (:all) do
      @rss = Feedzirra::Feed.parse(multiple_author_feed)
    end
    it "should have substring in text" do
      filtered = @rss.match_text_exact("ew of demo vid")
      filtered.size.should == 1
    end
    it "should have phrase in text" do
      filtered = @rss.match_text("slew of demo videos")
      filtered.size.should == 1
    end
    it "should have one word in text" do
      filtered = @rss.match_text_any_word("ipod kinect")
      filtered.size.should == 8
    end
    it "should have all words in text" do
      filtered = @rss.match_text_all_words("slew mission")
      filtered.size.should == 1
    end
  end

  it "should filter entries with images" do
    @rdf = Feedzirra::Feed.parse(sample_rdf_feed)
    filtered = @rdf.entries_with_images
    filtered.size.should == 1
  end

  it "should convert images to use absolute URLs" do
    # TODO: Ideally should test on a feed with non-absolute images
    @rdf = Feedzirra::Feed.parse(sample_rdf_feed)
    mapped = @rdf.entries_with_absolute_img_src
    # TODO: Not sure what goes here
  end

  it "should filter entries with links" do
    @rdf = Feedzirra::Feed.parse(sample_rdf_feed)
    filtered = @rdf.entries_with_links
    filtered.size.should == 8
  end
  
  it "should filter randomly" do
    @rss = Feedzirra::Feed.parse(multiple_author_feed)
    filtered = @rss.entries_randomly(0.5)
    filtered.size.should <= @rss.entries.size
  end
  
  pending "map entries"
  
  describe "calling the correct methods when using where and arguments" do
  end
  describe "calling the correct methods when using where_not and arguments" do
  end
end
