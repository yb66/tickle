# encoding: UTF-8

require 'spec_helper'
require_relative "../lib/tickle.rb"
require 'timecop'

module Tickle # for convenience

day = 86400

describe "Parsing" do

  describe "parse", :integration => true do

    context "Asked with an object that responds to :to_time" do
      describe "Returning it immediately" do
        let(:expected) { Date.parse("7th October 2015") }
        subject{ Tickle.parse(expected) }
        it { should == expected }
      end
    end

    context "Simple examples", :frozen => true do

      # Can't use second as it clashes with date ordinal names
      context "seconds" do
        subject{ Tickle.parse('seconds') }
        let(:expected) { {:next=>Time.parse("2010-05-09 20:57:37 +0000"), :expression=>"seconds", :starting=>Time.parse("2010-05-09 20:57:36 +0000"), :until=>nil} }
        it { should == expected }
      end

      # Other variant for seconds
      context "sec" do
        subject{ Tickle.parse('sec') }
        let(:expected) { {:next=>Time.parse("2010-05-09 20:57:37 +0000"), :expression=>"sec", :starting=>Time.parse("2010-05-09 20:57:36 +0000"), :until=>nil} }
        it { should == expected }
      end

      context "minute" do
        subject{ Tickle.parse('minute') }
        let(:expected) { {:next=>Time.parse("2010-05-09 20:58:36 +0000"), :expression=>"minute", :starting=>Time.parse("2010-05-09 20:57:36 +0000"), :until=>nil} }
        xit { should == expected }
      end

      context "hour" do
        subject{ Tickle.parse('hour') }
        let(:expected) { {:next=>Time.parse("2010-05-09 21:57:36 +0000"), :expression=>"hour", :starting=>Time.parse("2010-05-09 20:57:36 +0000"), :until=>nil} }
        xit { should == expected }
      end

      context "day" do
        subject{ Tickle.parse('day') }
        let(:expected) { {:next=>Time.parse("2010-05-10 20:57:36 +0000"), :expression=>"day", :starting=>Time.parse("2010-05-09 20:57:36 +0000"), :until=>nil} }
        it { should == expected }
      end

      context "week" do
        subject{ Tickle.parse('week') }
        let(:expected) { {:next=>Time.parse("2010-05-16 20:57:36 +0000"), :expression=>"week", :starting=>Time.parse("2010-05-09 20:57:36 +0000"), :until=>nil} }
        it { should == expected }
      end

      context "month" do
        subject{ Tickle.parse('month') }
        let(:expected) { {:next=>Time.parse("2010-06-09 20:57:36 +0000"), :expression=>"month", :starting=>Time.parse("2010-05-09 20:57:36 +0000"), :until=>nil} }
        it { should == expected }
      end

      context "year" do
        subject{ Tickle.parse('year') }
        let(:expected) { {:next=>Time.parse("2011-05-09 20:57:36 +0000"), :expression=>"year", :starting=>Time.parse("2010-05-09 20:57:36 +0000"), :until=>nil} }
        it { should == expected }
      end

      context "hourly" do
        subject{ Tickle.parse('hourly') }
        let(:expected) { {:next=>Time.parse("2010-05-09 21:57:36 +0000"), :expression=>"hourly", :starting=>Time.parse("2010-05-09 20:57:36 +0000"), :until=>nil} }
        xit { should == expected }
      end

      context "daily" do
        subject{ Tickle.parse('daily') }
        let(:expected) { {:next=>Time.parse("2010-05-10 20:57:36 +0000"), :expression=>"daily", :starting=>Time.parse("2010-05-09 20:57:36 +0000"), :until=>nil} }
        it { should == expected }
      end

      context "weekly" do
        subject{ Tickle.parse('weekly') }
        let(:expected) { {:next=>Time.parse("2010-05-16 20:57:36 +0000"), :expression=>"weekly", :starting=>Time.parse("2010-05-09 20:57:36 +0000"), :until=>nil} }
        it { should == expected }
      end

      context "monthly" do
        subject{ Tickle.parse('monthly') }
        let(:expected) { {:next=>Time.parse("2010-06-09 20:57:36 +0000"), :expression=>"monthly", :starting=>Time.parse("2010-05-09 20:57:36 +0000"), :until=>nil} }
        it { should == expected }
      end

      context "yearly" do
        subject{ Tickle.parse('yearly') }
        let(:expected) { {:next=>Time.parse("2011-05-09 20:57:36 +0000"), :expression=>"yearly", :starting=>Time.parse("2010-05-09 20:57:36 +0000"), :until=>nil} }
        it { should == expected }
      end

      context "3 seconds" do
        subject{ Tickle.parse('3 seconds') }
        let(:expected) { {:next=>Time.parse("2010-05-09 20:57:39 +0000"), :expression=>"3 seconds", :starting=>Time.parse("2010-05-09 20:57:36 +0000"), :until=>nil} }
        it { should == expected }
      end

      context "3 sec" do
        subject{ Tickle.parse('3 sec') }
        let(:expected) { {:next=>Time.parse("2010-05-09 20:57:39 +0000"), :expression=>"3 sec", :starting=>Time.parse("2010-05-09 20:57:36 +0000"), :until=>nil} }
        it { should == expected }
      end

      context "3 minutes" do
        subject{ Tickle.parse('3 minutes') }
        let(:expected) { {:next=>Time.parse("2010-05-09 21:00:36 +0000"), :expression=>"3 minutes", :starting=>Time.parse("2010-05-09 20:57:36 +0000"), :until=>nil} }
        xit { should == expected }
      end

      context "3 hours" do
        subject{ Tickle.parse('3 hours') }
        let(:expected) { {:next=>Time.parse("2010-05-09 23:57:36 +0000"), :expression=>"3 hours", :starting=>Time.parse("2010-05-09 20:57:36 +0000"), :until=>nil} }
        xit { should == expected }
      end

      context "3 days" do
        subject{ Tickle.parse('3 days') }
        let(:expected) { {:next=>Time.parse("2010-05-12 20:57:36 +0000"), :expression=>"3 days", :starting=>Time.parse("2010-05-09 20:57:36 +0000"), :until=>nil} }
        it { should == expected }
      end

      context "3 weeks" do
        subject{ Tickle.parse('3 weeks') }
        let(:expected) { {:next=>Time.parse("2010-05-30 20:57:36 +0000"), :expression=>"3 weeks", :starting=>Time.parse("2010-05-09 20:57:36 +0000"), :until=>nil} }
        it { should == expected }
      end

      context "3 months" do
        subject{ Tickle.parse('3 months') }
        let(:expected) { {:next=>Time.parse("2010-08-09 20:57:36 +0000"), :expression=>"3 months", :starting=>Time.parse("2010-05-09 20:57:36 +0000"), :until=>nil} }
        it { should == expected }
      end

      context "3 years" do
        subject{ Tickle.parse('3 years') }
        let(:expected) { {:next=>Time.parse("2013-05-09 20:57:36 +0000"), :expression=>"3 years", :starting=>Time.parse("2010-05-09 20:57:36 +0000"), :until=>nil} }
        it { should == expected }
      end

      context "other seconds" do
        subject{ Tickle.parse('other second') }
        let(:expected) { {:next=>Time.parse("2010-05-09 20:57:38 +0000"), :expression=>"other second", :starting=>Time.parse("2010-05-09 20:57:36 +0000"), :until=>nil} }
        xit { should == expected }
      end

      context "other sec" do
        subject{ Tickle.parse('other second') }
        let(:expected) { {:next=>Time.parse("2010-05-09 20:57:38 +0000"), :expression=>"other second", :starting=>Time.parse("2010-05-09 20:57:36 +0000"), :until=>nil} }
        xit { should == expected }
      end

      context "other minute" do
        subject{ Tickle.parse('other minute') }
        let(:expected) { {:next=>Time.parse("2010-05-09 20:59:36 +0000"), :expression=>"other minute", :starting=>Time.parse("2010-05-09 20:57:36 +0000"), :until=>nil} }
        xit { should == expected }
      end

      context "other hour" do
        subject{ Tickle.parse('other hour') }
        let(:expected) { {:next=>Time.parse("2010-05-09 22:57:36 +0000"), :expression=>"other hour", :starting=>Time.parse("2010-05-09 20:57:36 +0000"), :until=>nil} }
        xit { should == expected }
      end

      context "other day" do
        subject{ Tickle.parse('other day') }
        let(:expected) { {:next=>Time.parse("2010-05-11 20:57:36 +0000"), :expression=>"other day", :starting=>Time.parse("2010-05-09 20:57:36 +0000"), :until=>nil} }
        it { should == expected }
      end

      context "other week" do
        subject{ Tickle.parse('other week') }
        let(:expected) { {:next=>Time.parse("2010-05-23 20:57:36 +0000"), :expression=>"other week", :starting=>Time.parse("2010-05-09 20:57:36 +0000"), :until=>nil} }
        it { should == expected }
      end

      context "other month" do
        subject{ Tickle.parse('other month') }
        let(:expected) { {:next=>Time.parse("2010-07-09 20:57:36 +0000"), :expression=>"other month", :starting=>Time.parse("2010-05-09 20:57:36 +0000"), :until=>nil} }
        it { should == expected }
      end

      context "other year" do
        subject{ Tickle.parse('other year') }
        let(:expected) { {:next=>Time.parse("2012-05-09 20:57:36 +0000"), :expression=>"other year", :starting=>Time.parse("2010-05-09 20:57:36 +0000"), :until=>nil} }
        it { should == expected }
      end

      context "noon" do
        subject{ Tickle.parse('noon') }
        let(:expected) { {:next=>Time.parse("2010-05-10 12:00:00 +0000"), :expression=>"12:00", :starting=>Time.parse("2010-05-09 20:57:36 +0000"), :until=>nil} }
        xit { should == expected }
      end

      context "midnight" do
        subject{ Tickle.parse('noon') }
        let(:expected) { {:next=>Time.parse("2010-05-10 00:00:00 +0000"), :expression=>"00:00", :starting=>Time.parse("2010-05-09 20:57:36 +0000"), :until=>nil} }
        xit { should == expected }
      end

      context "Monday" do
        subject{ Tickle.parse('Monday') }
        let(:expected) { {:next=>Time.parse("2010-05-10 12:00:00 +0000"), :expression=>"monday", :starting=>Time.parse("2010-05-09 20:57:36 +0000"), :until=>nil} }
        it { should == expected }
      end

      context "Wednesday" do
        subject{ Tickle.parse('Wednesday') }
        let(:expected) { {:next=>Time.parse("2010-05-12 12:00:00 +0000"), :expression=>"wednesday", :starting=>Time.parse("2010-05-09 20:57:36 +0000"), :until=>nil} }
        it { should == expected }
      end

      context "Friday" do
        subject{ Tickle.parse('Friday') }
        let(:expected) { {:next=>Time.parse("2010-05-14 12:00:00 +0000"), :expression=>"friday", :starting=>Time.parse("2010-05-09 20:57:36 +0000"), :until=>nil} }
        it { should == expected }
      end

      context "With time specified", :frozen => true do
        context "Monday at 3am" do
          subject{ Tickle.parse('Monday at 3am') }
          let(:expected) { {:next=>Time.parse("2010-05-10 15:00:00 +0000"), :expression=>"monday 15:00", :starting=>Time.parse("2010-05-09 20:57:36 +0000"), :until=>nil} }
          xit { should == expected }
        end
        context "daily 16:23" do
          subject{ Tickle.parse('daily') }
          let(:expected) { {:next=>Time.parse("2010-05-10 16:23:00 +0000"), :expression=>"daily 16:23", :starting=>Time.parse("2010-05-09 20:57:36 +0000"), :until=>nil} }
          xit { should == expected }
        end
      end

      context "Given that start is in the past, respect now option in parse" do
        context "every other day" do
          subject{ Tickle.parse('every other day', {:start=>Time.parse("2009-05-09 00:00:00 +0000"), :now=>Time.parse("2009-05-09 00:00:00 +0000"), :until=>Time.parse("2017-10-21 00:00:00 +0000") }) }
          let(:expected) { {:next=>Time.parse("2009-05-11 00:00:00 +0000"), :expression=>"every other day", :starting=>Time.parse("2009-05-09 00:00:00 +0000"), :until=>nil} }
          it { should == expected }
        end
      end

      context "Given that now is in the future, 2020-04-01 00:00:00 +0000" do
        context "February" do
          subject{ Tickle.parse('February', {:start=>Time.parse("2020-04-01 00:00:00 +0000"), :now=>Time.parse("2020-04-01 00:00:00 +0000")}) }
          let(:expected) { {:next=>Time.parse("2021-02-01 12:00:00 +0000"), :expression=>"february", :starting=>Time.parse("2020-04-01 00:00:00 +0000"), :until=>nil} }
          it { should == expected }
        end

        context "May" do
          subject{ Tickle.parse('May', {:start=>Time.parse("2020-04-01 00:00:00 +0000"), :now=>Time.parse("2020-04-01 00:00:00 +0000")}) }
          let(:expected) { {:next=>Time.parse("2020-05-01 12:00:00 +0000"), :expression=>"may", :starting=>Time.parse("2020-04-01 00:00:00 +0000"), :until=>nil} }
          it { should == expected }
        end

        context "june" do
          subject{ Tickle.parse('june', {:start=>Time.parse("2020-04-01 00:00:00 +0000"), :now=>Time.parse("2020-04-01 00:00:00 +0000")}) }
          let(:expected) { {:next=>Time.parse("2020-06-01 12:00:00 +0000"), :expression=>"june", :starting=>Time.parse("2020-04-01 00:00:00 +0000"), :until=>nil} }
          it { should == expected }
        end

        context "beginning of the month" do
          subject{ Tickle.parse('beginning of the month', {:start=>Time.parse("2020-04-01 00:00:00 +0000"), :now=>Time.parse("2020-04-01 00:00:00 +0000")}) }
          let(:expected) { {:next=>Time.parse("2020-05-01 00:00:00 +0000"), :expression=>"beginning of the month", :starting=>Time.parse("2020-04-01 00:00:00 +0000"), :until=>nil} }
          it { should == expected }
        end

        context "middle of the month" do
          subject{ Tickle.parse('middle of the month', {:start=>Time.parse("2020-04-01 00:00:00 +0000"), :now=>Time.parse("2020-04-01 00:00:00 +0000")}) }
          let(:expected) { {:next=>Time.parse("2020-04-15 00:00:00 +0000"), :expression=>"middle of the month", :starting=>Time.parse("2020-04-01 00:00:00 +0000"), :until=>nil} }
          it { should == expected }
        end

        context "end of the month" do
          subject{ Tickle.parse('end of the month', {:start=>Time.parse("2020-04-01 00:00:00 +0000"), :now=>Time.parse("2020-04-01 00:00:00 +0000")}) }
          let(:expected) { {:next=>Time.parse("2020-04-30 00:00:00 +0000"), :expression=>"end of the month", :starting=>Time.parse("2020-04-01 00:00:00 +0000"), :until=>nil} }
          it { should == expected }
        end

        context "beginning of the year" do
          subject{ Tickle.parse('beginning of the year', {:start=>Time.parse("2020-04-01 00:00:00 +0000"), :now=>Time.parse("2020-04-01 00:00:00 +0000")}) }
          let(:expected) { {:next=>Time.parse("2021-01-01 00:00:00 +0000"), :expression=>"beginning of the year", :starting=>Time.parse("2020-04-01 00:00:00 +0000"), :until=>nil} }
          it { should == expected }
        end

        context "middle of the year" do
          subject{ Tickle.parse('middle of the year', {:start=>Time.parse("2020-04-01 00:00:00 +0000"), :now=>Time.parse("2020-04-01 00:00:00 +0000")}) }
          let(:expected) { {:next=>Time.parse("2020-06-15 00:00:00 +0000"), :expression=>"middle of the year", :starting=>Time.parse("2020-04-01 00:00:00 +0000"), :until=>nil} }
          it { should == expected }
        end

        context "end of the year" do
          subject{ Tickle.parse('end of the year', {:start=>Time.parse("2020-04-01 00:00:00 +0000"), :now=>Time.parse("2020-04-01 00:00:00 +0000")}) }
          let(:expected) { {:next=>Time.parse("2020-12-31 00:00:00 +0000"), :expression=>"end of the year", :starting=>Time.parse("2020-04-01 00:00:00 +0000"), :until=>nil} }
          it { should == expected }
        end

        context "the 3rd of May" do
          subject{ Tickle.parse('the 3rd of May', {:start=>Time.parse("2020-04-01 00:00:00 +0000"), :now=>Time.parse("2020-04-01 00:00:00 +0000")}) }
          let(:expected) { {:next=>Time.parse("2020-05-03 00:00:00 +0000"), :expression=>"the 3rd of may", :starting=>Time.parse("2020-04-01 00:00:00 +0000"), :until=>nil} }
          it { should == expected }
        end

        context "the 3rd of February" do
          subject{ Tickle.parse('the 3rd of February', {:start=>Time.parse("2020-04-01 00:00:00 +0000"), :now=>Time.parse("2020-04-01 00:00:00 +0000")}) }
          let(:expected) { {:next=>Time.parse("2021-02-03 00:00:00 +0000"), :expression=>"the 3rd of february", :starting=>Time.parse("2020-04-01 00:00:00 +0000"), :until=>nil} }
          it { should == expected }
        end

        context "the 3rd of February 2022" do
          subject{ Tickle.parse('the 3rd of February 2022', {:start=>Time.parse("2020-04-01 00:00:00 +0000"), :now=>Time.parse("2020-04-01 00:00:00 +0000")}) }
          let(:expected) { {:next=>Time.parse("2022-02-03 00:00:00 +0000"), :expression=>"the 3rd of february 2022", :starting=>Time.parse("2020-04-01 00:00:00 +0000"), :until=>nil} }
          it { should == expected }
        end

        context "the 3rd of Feb 2022" do
          subject{ Tickle.parse('the 3rd of Feb 2022', {:start=>Time.parse("2020-04-01 00:00:00 +0000"), :now=>Time.parse("2020-04-01 00:00:00 +0000")}) }
          let(:expected) { {:next=>Time.parse("2022-02-03 00:00:00 +0000"), :expression=>"the 3rd of feb 2022", :starting=>Time.parse("2020-04-01 00:00:00 +0000"), :until=>nil} }
          it { should == expected }
        end

        context "the 4th of the month" do
          subject{ Tickle.parse('the 4th of the month', {:start=>Time.parse("2020-04-01 00:00:00 +0000"), :now=>Time.parse("2020-04-01 00:00:00 +0000")}) }
          let(:expected) { {:next=>Time.parse("2020-04-04 00:00:00 +0000"), :expression=>"the 4th of the month", :starting=>Time.parse("2020-04-01 00:00:00 +0000"), :until=>nil} }
          it { should == expected }
        end

        context "the 10th of the month" do
          subject{ Tickle.parse('the 10th of the month', {:start=>Time.parse("2020-04-01 00:00:00 +0000"), :now=>Time.parse("2020-04-01 00:00:00 +0000")}) }
          let(:expected) { {:next=>Time.parse("2020-04-10 00:00:00 +0000"), :expression=>"the 10th of the month", :starting=>Time.parse("2020-04-01 00:00:00 +0000"), :until=>nil} }
          it { should == expected }
        end

        context "the tenth of the month" do
          subject{ Tickle.parse('the tenth of the month', {:start=>Time.parse("2020-04-01 00:00:00 +0000"), :now=>Time.parse("2020-04-01 00:00:00 +0000")}) }
          let(:expected) { {:next=>Time.parse("2020-04-10 00:00:00 +0000"), :expression=>"the tenth of the month", :starting=>Time.parse("2020-04-01 00:00:00 +0000"), :until=>nil} }
          it { should == expected }
        end

        context "first" do
          subject{ Tickle.parse('first', {:start=>Time.parse("2020-04-01 00:00:00 +0000"), :now=>Time.parse("2020-04-01 00:00:00 +0000")}) }
          let(:expected) { {:next=>Time.parse("2020-05-01 00:00:00 +0000"), :expression=>"first", :starting=>Time.parse("2020-04-01 00:00:00 +0000"), :until=>nil} }
          it { should == expected }
        end

        context "the first of the month" do
          subject{ Tickle.parse('the first of the month', {:start=>Time.parse("2020-04-01 00:00:00 +0000"), :now=>Time.parse("2020-04-01 00:00:00 +0000")}) }
          let(:expected) { {:next=>Time.parse("2020-05-01 00:00:00 +0000"), :expression=>"the first of the month", :starting=>Time.parse("2020-04-01 00:00:00 +0000"), :until=>nil} }
          it { should == expected }
        end

        context "the thirtieth" do
          subject{ Tickle.parse('the thirtieth', {:start=>Time.parse("2020-04-01 00:00:00 +0000"), :now=>Time.parse("2020-04-01 00:00:00 +0000")}) }
          let(:expected) { {:next=>Time.parse("2020-04-30 00:00:00 +0000"), :expression=>"the thirtieth", :starting=>Time.parse("2020-04-01 00:00:00 +0000"), :until=>nil} }
          it { should == expected }
        end

        context "the fifth" do
          subject{ Tickle.parse('the fifth', {:start=>Time.parse("2020-04-01 00:00:00 +0000"), :now=>Time.parse("2020-04-01 00:00:00 +0000")}) }
          let(:expected) { {:next=>Time.parse("2020-04-05 00:00:00 +0000"), :expression=>"the fifth", :starting=>Time.parse("2020-04-01 00:00:00 +0000"), :until=>nil} }
          it { should == expected }
        end

        context "the 1st Wednesday of the month" do
          subject{ Tickle.parse('the 1st wednesday of the month', {:start=>Time.parse("2020-04-01 00:00:00 +0000"), :now=>Time.parse("2020-04-01 00:00:00 +0000")}) }
          let(:expected) {
            {:next=>Time.parse("2020-05-01 00:00:00 +0000"), :expression=>"the 1st wednesday of the month", :starting=>Time.parse("2020-04-01 00:00:00 +0000"), :until=>nil}
          }
          it { should == expected }
        end

        context "the 3rd Sunday of May" do
          subject{ Tickle.parse('the 3rd Sunday of May', {:start=>Time.parse("2020-04-01 00:00:00 +0000"), :now=>Time.parse("2020-04-01 00:00:00 +0000")}) }
          let(:expected) { {:next=>Time.parse("2020-05-17 12:00:00 +0000"), :expression=>"the 3rd sunday of may", :starting=>Time.parse("2020-04-01 00:00:00 +0000"), :until=>nil} }
          it { should == expected }
        end

        context "the 3rd Sunday of the month" do
          subject{ Tickle.parse('the 3rd Sunday of the month', {:start=>Time.parse("2020-04-01 00:00:00 +0000"), :now=>Time.parse("2020-04-01 00:00:00 +0000")}) }
          let(:expected) { {:next=>Time.parse("2020-04-19 12:00:00 +0000"), :expression=>"the 3rd sunday of the month", :starting=>Time.parse("2020-04-01 00:00:00 +0000"), :until=>nil} }
          it { should == expected }
        end

        context "the 23rd of June" do
          subject{ Tickle.parse('the 23rd of June', {:start=>Time.parse("2020-04-01 00:00:00 +0000"), :now=>Time.parse("2020-04-01 00:00:00 +0000")}) }
          let(:expected) { {:next=>Time.parse("2020-06-23 00:00:00 +0000"), :expression=>"the 23rd of june", :starting=>Time.parse("2020-04-01 00:00:00 +0000"), :until=>nil} }
          it { should == expected }
        end

        context "the twenty third of June" do
          subject{ Tickle.parse('the twenty third of June', {:start=>Time.parse("2020-04-01 00:00:00 +0000"), :now=>Time.parse("2020-04-01 00:00:00 +0000")}) }
          let(:expected) { {:next=>Time.parse("2020-06-23 00:00:00 +0000"), :expression=>"the twenty third of june", :starting=>Time.parse("2020-04-01 00:00:00 +0000"), :until=>nil} }
          it { should == expected }
        end

        context "the thirty first of July" do
          subject{ Tickle.parse('the thirty first of July', {:start=>Time.parse("2020-04-01 00:00:00 +0000"), :now=>Time.parse("2020-04-01 00:00:00 +0000")}) }
          let(:expected) { {:next=>Time.parse("2020-07-31 00:00:00 +0000"), :expression=>"the thirty first of july", :starting=>Time.parse("2020-04-01 00:00:00 +0000"), :until=>nil} }
          it { should == expected }
        end

        context "the twenty first" do
          subject{ Tickle.parse('the twenty first', {:start=>Time.parse("2020-04-01 00:00:00 +0000"), :now=>Time.parse("2020-04-01 00:00:00 +0000")}) }
          let(:expected) { {:next=>Time.parse("2020-04-21 00:00:00 +0000"), :expression=>"the twenty first", :starting=>Time.parse("2020-04-01 00:00:00 +0000"), :until=>nil} }
          it { should == expected }
        end

        context "the twenty first of the month" do
          subject{ Tickle.parse('the twenty first of the month', {:start=>Time.parse("2020-04-01 00:00:00 +0000"), :now=>Time.parse("2020-04-01 00:00:00 +0000")}) }
          let(:expected) { {:next=>Time.parse("2020-04-21 00:00:00 +0000"), :expression=>"the twenty first of the month", :starting=>Time.parse("2020-04-01 00:00:00 +0000"), :until=>nil} }
          it { should == expected }
        end
      end

      context "beginning of the week" do
        subject{ Tickle.parse('beginning of the week') }
        let(:expected) { {:next=>Time.parse("2010-05-16 12:00:00 +0000"), :expression=>"beginning of the week", :starting=>Time.parse("2010-05-09 20:57:36 +0000"), :until=>nil} }
        it { should == expected }
      end

      context "middle of the week" do
        subject{ Tickle.parse('middle of the week') }
        let(:expected) { {:next=>Time.parse("2010-05-12 12:00:00 +0000"), :expression=>"middle of the week", :starting=>Time.parse("2010-05-09 20:57:36 +0000"), :until=>nil} }
        it { should == expected }
      end

      context "end of the week" do
        subject{ Tickle.parse('end of the week') }
        let(:expected) { {:next=>Time.parse("2010-05-15 12:00:00 +0000"), :expression=>"end of the week", :starting=>Time.parse("2010-05-09 20:57:36 +0000"), :until=>nil} }
        it { should == expected }
      end

    end

    context "Complex examples", :frozen => true do

      context "starting today and ending one week from now" do
        subject{ Tickle.parse('starting today and ending one week from now') }
        let(:expected) { {:next=>Time.parse("2010-05-10 22:00:00 +0000"), :expression=>"day", :starting=>Time.parse("2010-05-09 22:00:00 +0000"), :until=>Time.parse("2010-05-16 20:57:36 +0000")} }
        it { should == expected }
      end

      context "starting tomorrow and ending one week from now" do
        subject{ Tickle.parse('starting tomorrow and ending one week from now') }
        let(:expected) { {:next=>Time.parse("2010-05-10 12:00:00 +0000"), :expression=>"day", :starting=>Time.parse("2010-05-10 12:00:00 +0000"), :until=>Time.parse("2010-05-16 20:57:36 +0000")} }
        it { should == expected }
      end

      context "starting Monday repeat every month" do
        subject{ Tickle.parse('starting Monday repeat every month') }
        let(:expected) { {:next=>Time.parse("2010-05-10 12:00:00 +0000"), :expression=>"month", :starting=>Time.parse("2010-05-10 12:00:00 +0000"), :until=>nil} }
        it { should == expected }
      end

      context "starting May 13th repeat every week" do
        subject{ Tickle.parse('starting May 13th repeat every week') }
        let(:expected) { {:next=>Time.parse("2010-05-13 12:00:00 +0000"), :expression=>"week", :starting=>Time.parse("2010-05-13 12:00:00 +0000"), :until=>nil} }
        it { should == expected }
      end

      context "starting May 13th repeat every other day" do
        subject{ Tickle.parse('starting May 13th repeat every other day') }
        let(:expected) { {:next=>Time.parse("2010-05-13 12:00:00 +0000"), :expression=>"other day", :starting=>Time.parse("2010-05-13 12:00:00 +0000"), :until=>nil} }
        it { should == expected }
      end

      context "every other day starts May 13th" do
        subject{ Tickle.parse('every other day starts May 13th') }
        let(:expected) { {:next=>Time.parse("2010-05-13 12:00:00 +0000"), :expression=>"other day", :starting=>Time.parse("2010-05-13 12:00:00 +0000"), :until=>nil} }
        it { should == expected }
      end

      context "every other day starts May 13" do
        subject{ Tickle.parse('every other day starts May 13') }
        let(:expected) { {:next=>Time.parse("2010-05-13 12:00:00 +0000"), :expression=>"other day", :starting=>Time.parse("2010-05-13 12:00:00 +0000"), :until=>nil} }
        it { should == expected }
      end

      context "every other day starting May 13th" do
        subject{ Tickle.parse('every other day starting May 13th') }
        let(:expected) { {:next=>Time.parse("2010-05-13 12:00:00 +0000"), :expression=>"other day", :starting=>Time.parse("2010-05-13 12:00:00 +0000"), :until=>nil} }
        it { should == expected }
      end

      context "every other day starting May 13" do
        subject{ Tickle.parse('every other day starting May 13') }
        let(:expected) { {:next=>Time.parse("2010-05-13 12:00:00 +0000"), :expression=>"other day", :starting=>Time.parse("2010-05-13 12:00:00 +0000"), :until=>nil} }
        it { should == expected }
      end

      context "every week starts this wednesday" do
        subject{ Tickle.parse('every week starts this wednesday') }
        let(:expected) { {:next=>Time.parse("2010-05-12 12:00:00 +0000"), :expression=>"week", :starting=>Time.parse("2010-05-12 12:00:00 +0000"), :until=>nil} }
        it { should == expected }
      end

      context "every week starting this wednesday" do
        subject{ Tickle.parse('every week starting this wednesday') }
        let(:expected) { {:next=>Time.parse("2010-05-12 12:00:00 +0000"), :expression=>"week", :starting=>Time.parse("2010-05-12 12:00:00 +0000"), :until=>nil} }
        it { should == expected }
      end

      context "every other day starting May 1st 2021" do
        subject{ Tickle.parse('every other day starting May 1st 2021') }
        let(:expected) { {:next=>Time.parse("2021-05-01 12:00:00 +0000"), :expression=>"other day", :starting=>Time.parse("2021-05-01 12:00:00 +0000"), :until=>nil} }
        it { should == expected }
      end

      context "every other day starting May 1 2021" do
        subject{ Tickle.parse('every other day starting May 1 2021') }
        let(:expected) { {:next=>Time.parse("2021-05-01 12:00:00 +0000"), :expression=>"other day", :starting=>Time.parse("2021-05-01 12:00:00 +0000"), :until=>nil} }
        it { should == expected }
      end

      context "every other week starting this Sunday" do
        subject{ Tickle.parse('every other week starting this Sunday') }
        let(:expected) { {:next=>Time.parse("2010-05-16 12:00:00 +0000"), :expression=>"other week", :starting=>Time.parse("2010-05-16 12:00:00 +0000"), :until=>nil} }
        it { should == expected }
      end

      context "every week starting this wednesday until May 13th" do
        subject{ Tickle.parse('every week starting this wednesday until May 13th') }
        let(:expected) { {:next=>Time.parse("2010-05-12 12:00:00 +0000"), :expression=>"week", :starting=>Time.parse("2010-05-12 12:00:00 +0000"), :until=>Time.parse("2010-05-13 12:00:00 +0000")} }
        it { should == expected }
      end

      context "every week starting this wednesday ends May 13th" do
        subject{ Tickle.parse('every week starting this wednesday ends May 13th') }
        let(:expected) { {:next=>Time.parse("2010-05-12 12:00:00 +0000"), :expression=>"week", :starting=>Time.parse("2010-05-12 12:00:00 +0000"), :until=>Time.parse("2010-05-13 12:00:00 +0000")} }
        it { should == expected }
      end

      context "every week starting this wednesday ending May 13th" do
        subject{ Tickle.parse('every week starting this wednesday ending May 13th') }
        let(:expected) { {:next=>Time.parse("2010-05-12 12:00:00 +0000"), :expression=>"week", :starting=>Time.parse("2010-05-12 12:00:00 +0000"), :until=>Time.parse("2010-05-13 12:00:00 +0000")} }
        it { should == expected }
      end
    end
  end
end

end # of module
