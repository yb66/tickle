require 'spec_helper'
require_relative "../lib/tickle/patterns.rb"

module Tickle # for convenience

  # TODO move these to patterns_spec
  describe "Patterns" do
    let(:example1) { "every thursday starting tomorrow until May 15th" }
    let(:example2) { "starting thursday every Tuesday until May 15th" }
    let(:example3) { "every thursday starting tomorrow until May 15th" }
    let(:example4) { "starting thursday on the 5th day of each month until May 15th" }
    describe "START_EVERY_REGEX" do
      context "Given example1" do
        subject { Patterns::START_EVERY_REGEX.match example1 }
        it { should be_nil }
      end
      context "Given example2" do
        subject { Patterns::START_EVERY_REGEX.match example2 }
        it { should_not be_nil }
      end
      context "Given example3" do
        subject { Patterns::START_EVERY_REGEX.match example3 }
        it { should be_nil }
      end
      context "Given example4" do
        subject { Patterns::START_EVERY_REGEX.match example4 }
        it { should_not be_nil }
      end
    end
    describe "EVERY_START_REGEX" do
      context "Given example1" do
        subject { Patterns::EVERY_START_REGEX.match example1 }
        it { should_not be_nil }
      end
      context "Given example2" do
        subject { Patterns::EVERY_START_REGEX.match example2 }
        it { should be_nil }
      end
      context "Given example3" do
        subject { Patterns::EVERY_START_REGEX.match example3 }
        it { should_not be_nil }
      end
      context "Given example4" do
        subject { Patterns::EVERY_START_REGEX.match example4 }
        it { should be_nil }
      end
    end
    describe "START_ENDING_REGEX" do
      context "Given example1" do
        subject { Patterns::START_ENDING_REGEX.match example1 }
        it { should be_nil }
      end
      context "Given example2" do
        subject { Patterns::START_ENDING_REGEX.match example2 }
        it { should_not be_nil }
      end
      context "Given example3" do
        subject { Patterns::START_ENDING_REGEX.match example3 }
        it { should be_nil }
      end
      context "Given example4" do
        subject { Patterns::START_ENDING_REGEX.match example4 }
        it { should_not be_nil }
      end
    end


    describe "SET_IDENTIFIER" do
      subject { Patterns::SET_IDENTIFIER }
      context "Given 'every'" do
        it { should match "every" }
      end
      context "Given 'each'" do
        it { should match "each" }
      end
      context "Given 'on'" do
        it { should match "on" }
      end
      context "Given 'on the'" do
        it { should match "on the" }
      end
      context "Given 'repeat'" do
        it { should match "repeat" }
      end
    end

    describe "ON_THE" do
      subject { Patterns::ON_THE }
      context "Given 'on'" do
        it { should match "on" }
      end
      context "Given 'on the'" do
        it { should match "on the" }
      end
    end

    describe "END_OR_UNTIL" do
      subject { Patterns::END_OR_UNTIL }
      context "Given 'end'" do
        it { should match "end" }
      end
      context "Given 'ends'" do
        it { should match "ends" }
      end
      context "Given 'ends on'" do
        it { should match "ends on" }
      end
      context "Given 'ends on the'" do
        it { should match "ends on the" }
      end
      context "Given 'ending'" do
        it { should match "ending" }
      end
      context "Given 'ending on'" do
        it { should match "ending on" }
      end
      context "Given 'ending on the'" do
        it { should match "ending on the" }
      end
      context "Given 'until'" do
        it { should match "until" }
      end
      context "Given 'until the'" do
        it { should match "until the" }
      end
      context "Given 'send'" do
        it { should_not match "send" }
      end
    end

    describe "PLURAL_OR_PRESENT_PARTICIPLE" do
      subject { Patterns::PLURAL_OR_PRESENT_PARTICIPLE }
      context "Given 's'" do
        it { should match "s" }
      end
      context "Given 'ing'" do
        it { should match "ing" }
      end
    end

    describe "START" do
      subject { Patterns::START }
      context "Given 'starting'" do
        it { should match "starting" }
      end
      context "Given 'starts'" do
        it { should match "starts" }
      end
      context "Given 'start'" do
        it { should match "start" }
      end
    end

    describe "START_EVERY_REGEX" do
      subject { Patterns::START_EVERY_REGEX }
      let(:phrase) { "starting today on the 12th" }
      context "Given 'starting today on the 12th'" do
        it { should match phrase  }
        describe "Captures" do
          subject { Patterns::START_EVERY_REGEX.match "starting today on the 12th" }
          its([:start]) { should == "today" }
          its([:event]) { should == "12th" }
        end
      end
    end

    describe "START_ENDING_REGEX" do
      subject { Patterns::START_ENDING_REGEX }
      context "Given 'starting today until the 12th'" do
        let(:phrase) { "starting today until the 12th" }
        it { should match phrase  }
        describe "Captures" do
          subject { Patterns::START_ENDING_REGEX.match phrase }
          its([:start]) { should == "today" }
          its([:finish]) { should == "12th" }
        end
      end
      context "Given 'starting today and ending one week from now'" do
        let(:phrase) { "starting today and ending one week from now"}
        it { should match phrase  }
        describe "Captures" do
          subject { Patterns::START_ENDING_REGEX.match phrase }
          its([:start]) { should == "today" }
          its([:finish]) { should == "one week from now" }
        end
      end
    end

    describe "EVERY_START_REGEX" do
      subject { Patterns::EVERY_START_REGEX }
      context "Given 'every Monday starting the 12th'" do
        let(:phrase) { "every Monday starting on the 12th" }
        it { should match phrase  }
        describe "Captures" do
          subject { Patterns::EVERY_START_REGEX.match phrase }
          its([:start]) { should == "12th" }
          its([:event]) { should == "Monday" }
        end
      end
    end

    describe "PROCESS_FOR_ENDING" do
      subject { Patterns::PROCESS_FOR_ENDING }
      context "Given 'Monday until the 12th'" do
        let(:phrase) { "Monday until the 12th" }
        it { should match phrase  }
        describe "Captures" do
          subject { Patterns::PROCESS_FOR_ENDING.match phrase }
          its([:target]) { should == "Monday" }
          its([:ending]) { should == "12th" }
        end
      end
      context "Given 'Tuesday ending on the 12th'" do
        let(:phrase) { "Tuesday ending on the 12th" }
        it { should match phrase  }
        describe "Captures" do
          subject { Patterns::PROCESS_FOR_ENDING.match phrase }
          its([:target]) { should == "Tuesday" }
          its([:ending]) { should == "12th" }
        end
      end
    end


  end
end