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
  
  describe Machinist::Shop do
    before(:each) do
      Machinist::Shop.instance.reset_warehouse
      Post.blueprint { }
      Comment.blueprint { }
    end
    
    it "should cache an object" do
      post_a = Post.make
      post_a.should be_a(Post)
      
      Machinist::Shop.instance.reset
      post_b = Post.make
      post_b.duped_from.should == post_a.duped_from
    end
    
    it "should cache an object with attributes" do
      post_a = Post.make(:title => "Test Title")
      post_a.should be_a(Post)
      post_a.title.should == "Test Title"

      Machinist::Shop.instance.reset
      post_b = Post.make(:title => "Test Title")
      post_b.duped_from.should == post_a.duped_from
      post_b.title.should == "Test Title"
    end
    
    it "should cache multiple objects with the same class and attributes" do
      post_a = Post.make(:title => "Test Title")
      post_b = Post.make(:title => "Test Title")

      Machinist::Shop.instance.reset
      post_c = Post.make(:title => "Test Title")
      post_c.duped_from.should == post_a.duped_from
      post_c.title.should == "Test Title"
      post_d = Post.make(:title => "Test Title")
      post_d.duped_from.should == post_b.duped_from
      post_d.title.should == "Test Title"
    end
    
    it "should not confuse objects with different attributes" do
      post_a = Post.make(:title => "Title A")
      post_a.should be_a(Post)
      post_a.title.should == "Title A"

      Machinist::Shop.instance.reset
      post_b = Post.make(:title => "Title B")
      post_b.duped_from.should_not == post_a.duped_from
      post_b.title.should == "Title B"
    end
    
    it "should not confuse objects of different classes" do
      post = Post.make(:title => "Test Title")
      post.should be_a(Post)
      post.title.should == "Test Title"

      Machinist::Shop.instance.reset
      comment = Comment.make(:author => "Test Author")
      comment.should be_a(Comment)
      comment.author.should == "Test Author"
    end
        
    it "should ensure future copies of a cached object do not reflect changes to the original" do
      post_a = Post.make(:title => "Test Title")
      post_a.title = "Changed Title"
      
      Machinist::Shop.instance.reset
      post_b = Post.make(:title => "Test Title")
      post_b.duped_from.should == post_a.duped_from
      post_b.title.should == "Test Title"
    end
    
  end
end
