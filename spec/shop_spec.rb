require File.dirname(__FILE__) + '/spec_helper'
require 'machinist'
require 'logger'

module CachingSpecs
  
  class Post < ActiveRecord::Base
    has_many :comments
  end
  
  class Comment < ActiveRecord::Base
    belongs_to :post
  end
  
  describe Machinist::Shop do
    before(:suite) do
      logger = Logger.new(File.dirname(__FILE__) + "/log/test.log")
      logger.level = Logger::DEBUG
      ActiveRecord::Base.logger = logger
      # FIXME: Can we test against sqlite?
      # ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
      ActiveRecord::Base.establish_connection(
        :adapter  => "mysql",
        :database => "machinist",
        :host     => "localhost",
        :username => "root",
        :password => ""
      )
      load(File.dirname(__FILE__) + "/db/schema.rb")
    end
  
    before(:each) do
      Machinist::Shop.instance.reset_warehouse
      Post.blueprint { }
      Comment.blueprint { }
    end
    
    def fake_test
      Post.transaction do
        Machinist::Shop.instance.reset
        yield
        raise ActiveRecord::Rollback
      end
    end
    
    it "should cache an object" do
      post = Post.make
      post.should be_a(Post)
      
      Machinist::Shop.instance.reset
      Post.make.should == post
      Post.make.should_not == post
    end
    
    it "should cache an object with attributes" do
      post = Post.make(:title => "Test Title")
      post.should be_a(Post)
      post.title.should == "Test Title"
    
      Machinist::Shop.instance.reset
      Post.make(:title => "Test Title").should == post
      Post.make(:title => "Test Title").should_not == post
    end
    
    it "should ensure future copies of a cached object do not reflect changes to the original" do
      post = nil
      
      fake_test do
        post = Post.make(:title => "Test Title")
        post.title = "Changed Title"
        post.save!
      end
      
      fake_test do
        new_post = Post.make(:title => "Test Title")
        new_post.should == post
        new_post.title.should == "Test Title"
      end
    end
    
    # it "should cache multiple objects with the same class and attributes" do
    #   post_a = Post.make(:title => "Test Title")
    #   post_b = Post.make(:title => "Test Title")
    # 
    #   Machinist::Shop.instance.reset
    #   post_c = Post.make(:title => "Test Title")
    #   post_c.duped_from.should == post_a.duped_from
    #   post_c.title.should == "Test Title"
    #   post_d = Post.make(:title => "Test Title")
    #   post_d.duped_from.should == post_b.duped_from
    #   post_d.title.should == "Test Title"
    # end
    # 
    # it "should not confuse objects with different attributes" do
    #   post_a = Post.make(:title => "Title A")
    #   post_a.should be_a(Post)
    #   post_a.title.should == "Title A"
    # 
    #   Machinist::Shop.instance.reset
    #   post_b = Post.make(:title => "Title B")
    #   post_b.duped_from.should_not == post_a.duped_from
    #   post_b.title.should == "Title B"
    # end
    # 
    # it "should not confuse objects of different classes" do
    #   post = Post.make(:title => "Test Title")
    #   post.should be_a(Post)
    #   post.title.should == "Test Title"
    # 
    #   Machinist::Shop.instance.reset
    #   comment = Comment.make(:author => "Test Author")
    #   comment.should be_a(Comment)
    #   comment.author.should == "Test Author"
    # end
    
  end
end
