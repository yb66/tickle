require 'spec_helper'
require_relative "../lib/tickle/token.rb"
require 'rspec/its'

module Tickle # for convenience

describe "Token" do

  describe "The basics" do
    When(:token) { Token.new( "" ) }
    Then { token.kind_of? String }
    Then { token.respond_to? :original }
    Then { token.respond_to? :word }
    Then { token.respond_to? :type }
    Then { token.respond_to? :interval }
    Then { token.respond_to? :start }
    Then { token.respond_to? :update! }
    Then { token.respond_to? :normalize! }
  end


  describe "Instantation" do
    context "Given a token" do
      context "and no options" do
        When(:token) { Token.new( "Today" ) }
        Then { token.original == "Today" }
        Then { token.word == "today" }
        Then { token.type.nil? }
        Then { token.interval.nil? }
        Then { token.start.nil? }
        Then { token == "Today" }
      end
    end
  end

  describe "After normalization" do
    context "Given a token" do
      context "That is not a number" do
        context "and no options" do
          subject { Token.new( "Today" ) }
          it { should == "Today" }
          its(:word) { should == "today" }
        end
      end
      context "That is a number" do
        context "and no options" do
          subject { Token.new( "Twenty" ) }
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
    When(:tokens) { Tokens.new "Every Monday" }
    Then { tokens == ["Monday"] }
    Then { tokens.all?{|token| token.kind_of? Token } }
  end


  describe "combine_multiple_numbers" do
    context "When given compound numbers" do
      context "like 'twenty first'" do
        Given(:tokens) {
          tokens = Tokens.new []
          tokens.replace [
            Token.new("twenty", word: "20", type: :number, start: 20, interval: 20),
            Token.new("first", word: "1st", type: :ordinal, start: 1, interval: 1),
          ]
          tokens
        }
        When(:first) { tokens.combine_multiple_numbers.first }
        Then { first.original == "twenty first" } 
        And { first.word == "21st" }
        And { first.type == :ordinal }
        And { first.start == "21" }
        And { first.interval ==  365 }
      end
    end

  end

end

end