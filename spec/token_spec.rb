require 'spec_helper'
require_relative "../lib/tickle/token.rb"
require 'rspec/its'

module Tickle # for convenience

describe "Token" do

  describe "The basics" do
    subject { Token.new( "" ) }
    it { should be_a_kind_of ::String }
    it { should respond_to :original }
    it { should respond_to :word }
    it { should respond_to :type }
    it { should respond_to :interval }
    it { should respond_to :start }
    it { should respond_to :update! }
    it { should respond_to :normalize! }
  end


  describe "Instantation" do
    context "Given a token" do
      context "and no options" do
        subject { Token.new( "Today" ) }
        its(:original) { should == "Today" }
        its(:word) { should be_nil }
        its(:type) { should be_nil }
        its(:interval) { should be_nil }
        its(:start) { should be_nil }
        it { should == "Today" }
      end
    end
  end

  describe "After normalization" do
    context "Given a token" do
      context "That is not a number" do
        context "and no options" do
          subject { Token.new( "Today" ).normalize! }
          it { should == "Today" }
          its(:word) { should == "today" }
        end
      end
      context "That is a number" do
        context "and no options" do
          subject { Token.new( "Twenty" ).normalize! }
          it { should == "Twenty" }
          its(:word) { should == "20" }
        end
      end
    end
  end


  describe "update!" do
    pending
  end


  describe "tokenize" do
    subject { Token.tokenize "Next Monday" }
    it { should == ["Next", "Monday"] }
    its(:first) { should be_a_kind_of Token }
  end

end

end