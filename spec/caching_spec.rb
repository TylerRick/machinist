require File.dirname(__FILE__) + '/spec_helper'
require 'machinist'

module CachingSpecs
  
  class Post
    attr_accessor :title, :body
    
    attr_reader :duped_from
    
    def dup
      @duped_from = self
      super
    end
  end
  
  class Comment
    attr_accessor :author, :body
  end
  
  describe "Caching" do
    before do
      @object_cache = Machinist::ObjectCache.new
      test_manager = Machinist::TestManager.new(@object_cache)
      Post.blueprint { }
      Comment.blueprint { }
    end
    
    it "should cache an object" do
      manager_a = Machinist::TestManager.new(@object_cache)
      post_a = manager_a.make(Post)
      post_a.should be_a(Post)
      
      manager_b = Machinist::TestManager.new(@object_cache)
      post_b = manager_b.make(Post)
      post_b.duped_from.should == post_a.duped_from
    end
    
    it "should cache an object with attributes" do
      manager_a = Machinist::TestManager.new(@object_cache)
      post_a = manager_a.make(Post, :title => "Test Title")
      post_a.should be_a(Post)
      post_a.title.should == "Test Title"

      manager_b = Machinist::TestManager.new(@object_cache)
      post_b = manager_b.make(Post, :title => "Test Title")
      post_b.duped_from.should == post_a.duped_from
      post_b.title.should == "Test Title"
    end
    
    it "should cache multiple objects with the same class and attributes" do
      manager_a = Machinist::TestManager.new(@object_cache)
      post_a = manager_a.make(Post, :title => "Test Title")
      post_b = manager_a.make(Post, :title => "Test Title")

      manager_b = Machinist::TestManager.new(@object_cache)
      post_c = manager_b.make(Post, :title => "Test Title")
      post_c.duped_from.should == post_a.duped_from
      post_c.title.should == "Test Title"
      post_d = manager_b.make(Post, :title => "Test Title")
      post_d.duped_from.should == post_b.duped_from
      post_d.title.should == "Test Title"
    end
    
    it "should not confuse objects with different attributes" do
      manager_a = Machinist::TestManager.new(@object_cache)
      post_a = manager_a.make(Post, :title => "Title A")
      post_a.should be_a(Post)
      post_a.title.should == "Title A"

      manager_b = Machinist::TestManager.new(@object_cache)
      post_b = manager_b.make(Post, :title => "Title B")
      post_b.duped_from.should_not == post_a.duped_from
      post_b.title.should == "Title B"
    end
    
    it "should not confuse objects of different classes" do
      manager_a = Machinist::TestManager.new(@object_cache)
      post = manager_a.make(Post, :title => "Test Title")
      post.should be_a(Post)
      post.title.should == "Test Title"

      manager_b = Machinist::TestManager.new(@object_cache)
      comment = manager_b.make(Comment, :author => "Test Author")
      comment.should be_a(Comment)
      comment.author.should == "Test Author"
    end
        
    it "should ensure future copies of a cached object do not reflect changes to the original" do
      manager_a = Machinist::TestManager.new(@object_cache)
      post_a = manager_a.make(Post, :title => "Test Title")
      
      post_a.title = "Changed Title"
      
      manager_b = Machinist::TestManager.new(@object_cache)
      post_b = manager_b.make(Post, :title => "Test Title")
      post_b.duped_from.should == post_a.duped_from
      post_b.title.should == "Test Title"
    end
    
  end
end
