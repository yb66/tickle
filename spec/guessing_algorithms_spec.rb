require 'spec_helper'
require_relative "../lib/tickle/handler.rb"
require_relative "../lib/tickle/token.rb"


describe "Algorithms" do

  describe "guess_ordinal_and_unit" do
    Given!(:start) { Time.parse("2 Apr 2020 00:00:00 +0000") }
    tz = ENV["TZ"]
    before do
      Timecop.freeze start
      ENV["TZ"] = "UTC"
    end
    after do
      Timecop.return
      ENV["TZ"] = tz
    end
    Given(:algo) { Tickle::Handler::GuessAlgorithms[:guess_ordinal_and_unit] }
    Given(:tokens) { Tickle::Tokens.new "1st wednesday month" }
#    Given(:tokens) { Marshal.load File.read "tokens" }
    Given(:expected) { Time.parse("8 Apr 2020 12:00:00 +0000") }
    When(:next_occurrence){ algo.call tokens, start }
    Then { next_occurrence == expected }
  end
end