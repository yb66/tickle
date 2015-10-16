require "spec_helper"
require_relative "../lib/tickle/helpers.rb"


module Tickle # for convenience


describe "Helpers module" do

  describe "combine_multiple_numbers" do
    subject(:out) { Helpers.combine_multiple_numbers tokens}
    context "When given an empty set" do
      let(:tokens) { [] }
      it { should == [] }
    end
    context "When given compound numbers" do
      context "like 'twenty first'" do
        let(:tokens) { [
          Token.new("twenty", word: "20", type: :number, start: 20, interval: 20),
          Token.new("first", word: "1st", type: :ordinal, start: 1, interval: 1),
        ] }
        subject{ out.first }
        its(:original) { should == "twenty first" } 
        its(:word) { should == "21st" }
        its(:type) { should == :ordinal }
        its(:start) { should == "21"}
        its(:interval) {should ==  365 }
      end
    end
  
  end

end


end # of convenience