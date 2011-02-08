require 'feedzirra'

module FilterProcs
  # mix this into feed, or whatever else has an entries object
  
  def find_all_by_string(string)
    self.entries = self.entries.find_all { |entry|
      # TODO: Should not consider any embedded HTML
      # TODO: Should consider any other attributes you care about
      entry.title.include?(string) || entry.content.include?(string)
    }
  end
  
  def reject_by_string(string)
    self.entries = self.entries.reject { |entry|
      # TODO: Should not consider any embedded HTML
      # TODO: Should consider any other attributes you care about
      entry.title.include?(string) || entry.content.include?(string)
    }
  end
  
  def find_all_by_author(author_name)
    self.entries = self.entries.find_all { |entry| 
      entry.author.include?(author_name)
    }
  end
  
  def reject_by_author(author_name)
    self.entries = self.entries.reject { |entry|
      entry.author.include?(author_name)
    }
  end
  
  def find_all_with_image
    puts "leave only entries with images"
  end
  
  def reject_with_image
    puts "remove entries with images"
  end
  
  def map_to_images
    puts "map this feed to images"
  end
end

# TODO: reopen the Parser classes
# You would do this for any other feed parser you implement
# Or if you switch backends from Feedzirra you can mix in appropriately
[
  Feedzirra::Parser::Atom, Feedzirra::Parser::AtomFeedBurner,
  Feedzirra::Parser::ITunesRSS, Feedzirra::Parser::RSS
].each do |klass|
  klass.class_eval do
    include FilterProcs
  end
end