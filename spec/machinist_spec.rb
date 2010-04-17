require File.dirname(__FILE__) + '/spec_helper'
require 'machinist'

module MachinistSpecs
  
  class Person
    attr_accessor :name, :admin
  end

  class Post
    attr_accessor :title, :body, :published
  end

  class Grandpa
    attr_accessor :name
  end
  
  class Dad < Grandpa
    attr_accessor :name
  end

  class Son < Dad
    attr_accessor :name
  end

  describe Machinist do
    before(:each) do
      [Person, Post, Grandpa, Dad, Son].each(&:clear_blueprints!)
    end

    it "should raise for make on a class with no blueprint" do
      lambda { Person.make }.should raise_error(RuntimeError, "No blueprint for class MachinistSpecs::Person")
    end
  
    it "should set an attribute on the constructed object from a block in the blueprint" do
      Person.blueprint do
        name { "Fred" }
      end
      Person.make.name.should == "Fred"
    end
  
    it "should let the blueprint override an attribute with a default value" do
      Post.blueprint do
        published { false }
      end
      Post.make.published.should be_false
    end
  
    it "should allow overridden attribute names to be strings" do
      Person.blueprint do
        name { "Fred" }
      end
      Person.make("name" => "Bill").name.should == "Bill"
    end
  
    it "should override an attribute from the blueprint with a passed-in attribute" do
      block_called = false
      Person.blueprint do
        name { block_called = true; "Fred" }
      end
      Person.make(:name => "Bill").name.should == "Bill"
      block_called.should be_false
    end
  
    it "should call a passed-in block with the object being constructed" do
      Person.blueprint { }
      block_called = false
      Person.make do |person|
        block_called = true
        person.class.should == Person
      end
      block_called.should be_true
    end
  
    it "should provide access to the object being constructed from within the blueprint" do
      person = nil
      Person.blueprint { person = object }
      Person.make
      person.class.should == Person
    end
  
    it "should allow reading of a previously assigned attribute from within the blueprint" do
      Post.blueprint do
        title { "Test" }
        body  { title }
      end
      Post.make.body.should == "Test"
    end
    
    it "should allow passing a block to make" do
      Post.blueprint do
        title { "Test" }
      end
      result = Post.make do |post|
        post.title.should == "Test"
        "result"
      end
      result.should == "result"
    end
  
    describe "blueprint inheritance" do
      it "should inherit blueprinted attributes from the parent class" do
        Dad.blueprint do
          name { "Fred" }
        end
        Son.blueprint { }
        Son.make.name.should == "Fred"
      end

      it "should override blueprinted attributes in the child class" do
        Dad.blueprint do
          name { "Fred" }
        end
        Son.blueprint do
          name { "George" }
        end
        Dad.make.name.should == "Fred"
        Son.make.name.should == "George"
      end

      it "should inherit from blueprinted attributes in ancestor class" do
        Grandpa.blueprint do
          name { "Fred" }
        end
        Son.blueprint { }
        Grandpa.make.name.should == "Fred"
        lambda { Dad.make }.should raise_error(RuntimeError)
        Son.make.name.should == "Fred"
      end
    end

    describe "clear_blueprints! method" do
      it "should clear the blueprint" do
        Person.blueprint {}
        Person.clear_blueprints!
        lambda { Person.make }.should raise_error(RuntimeError)
      end
    end
    
  end
end
