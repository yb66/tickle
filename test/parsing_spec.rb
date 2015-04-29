require_relative 'spec_helper'

def set_now_to now
  Timecop.freeze now
end

describe "parsing strings to get timeframes" do

  let(:parse) { ->(x) { Tickle.parse x } }

  let(:date_matcher) { ->(x, y) { x.to_i.must_equal y.to_i } }

  describe "the basics" do

    [
      Time.parse('2015-04-27 15:19:14 -0500'),
      Time.parse('2015-01-01 15:19:14 -0500'),
      Time.parse('2017-12-25'),
    ].each do |now|

      [
        ['day',          now, now + 1.day,   nil, 'day'],
        ['every day',    now, now + 1.day,   nil, 'day'],
        ['every week',   now, now + 1.week,  nil, 'week'],
        ['every month',  now, now + 1.month, nil, 'month'],
        ['every year',   now, now + 1.year,  nil, 'year'],
        ###
        ['daily',        now, now + 1.day,   nil, 'daily'],
        ['weekly',       now, now + 1.week,  nil, 'weekly'],
        ['monthly',      now, now + 1.month, nil, 'monthly'],
        ['yearly',       now, now + 1.year,  nil, 'yearly'],
        ###
        ['every 3 days',   now, now + 3.days,   nil,  '3 days'],
        ['every 3 weeks',  now, now + 3.weeks,  nil,  '3 weeks'],
        ['every 3 months', now, now + 3.months, nil,  '3 months'],
        ['every 3 years',  now, now + 3.years,  nil,  '3 years'],
        ###
        ['every 9 days',   now, now + 9.days,   nil,  '9 days'],
        ['every 9 weeks',  now, now + 9.weeks,  nil,  '9 weeks'],
        ['every 9 months', now, now + 9.months, nil,  '9 months'],
        ['every 9 years',  now, now + 9.years,  nil,  '9 years'],
        ###
        ['every other day',   now, now + 2.days,   nil,  'other day'],
        ['every other week',  now, now + 2.weeks,  nil,  'other week'],
        ['every other month', now, now + 2.months, nil,  'other month'],
        ['every other year',  now, now + 2.years,  nil,  'other year'],
      ].map { |x| Struct.new(:input, :start, :next, :until, :expression).new(*x) }.each do |example|

        describe "parsing from #{now}" do

          before { set_now_to now }

          it example.input do
            result = parse.call example.input
            date_matcher.call(result[:starting], example.start)
            date_matcher.call(result[:next],     example.next)
            if example.until
              result[:until].must_equal example.until
            else
              result[:until].nil?.must_equal true
            end
            result[:expression].must_equal example.expression
          end

        end

      end

    end

    
    describe "specific dates of the week"  do

      describe "every weekday" do

        describe "at the beginning of the week, midday (sunday)" do

          [
            Time.parse('2015-04-26 00:00:00 -0500'),
          ].each do |now|

            [
              ['every Monday',    now, now + 1.day  + 12.hours,  nil,  'monday'],
              ['every Tuesday',   now, now + 2.days + 12.hours,  nil,  'tuesday'],
              ['every Wednesday', now, now + 3.days + 12.hours,  nil,  'wednesday'],
              ['every Thursday',  now, now + 4.days + 12.hours,  nil,  'thursday'],
              ['every Friday',    now, now + 5.days + 12.hours,  nil,  'friday'],
              ['every Saturday',  now, now + 6.days + 12.hours,  nil,  'saturday'],
              ['every Sunday',    now, now + 7.days + 12.hours,  nil,  'sunday'],
            ].map { |x| Struct.new(:input, :start, :next, :until, :expression).new(*x) }.each do |example|

              describe example.input do

                before { set_now_to now }

                it 'should match the expected day' do
                  result = parse.call example.input
                  date_matcher.call(result[:starting], example.start)
                  date_matcher.call(result[:next],  example.next)
                  if example.until
                    result[:until].must_equal example.until
                  else
                    result[:until].nil?.must_equal true
                  end
                  result[:expression].must_equal example.expression
                end

              end

            end

          end

        end

        describe "at the end of the week, midday (sunday)" do

          [
            Time.parse('2015-04-25 00:00:00 -0500'),
          ].each do |now|

            [
              ['every Sunday',    now, now + 1.days + 12.hours,  nil,  'sunday'],
              ['every Monday',    now, now + 2.day  + 12.hours,  nil,  'monday'],
              ['every Tuesday',   now, now + 3.days + 12.hours,  nil,  'tuesday'],
              ['every Wednesday', now, now + 4.days + 12.hours,  nil,  'wednesday'],
              ['every Thursday',  now, now + 5.days + 12.hours,  nil,  'thursday'],
              ['every Friday',    now, now + 6.days + 12.hours,  nil,  'friday'],
              ['every Saturday',  now, now + 7.days + 12.hours,  nil,  'saturday'],
            ].map { |x| Struct.new(:input, :start, :next, :until, :expression).new(*x) }.each do |example|

              describe example.input do

                before { set_now_to now }

                it 'should match the expected day' do
                  result = parse.call example.input
                  date_matcher.call(result[:starting], example.start)
                  date_matcher.call(result[:next],  example.next)
                  if example.until
                    result[:until].must_equal example.until
                  else
                    result[:until].nil?.must_equal true
                  end
                  result[:expression].must_equal example.expression
                end

              end

            end

          end

        end

      end

    #assert_date_match(@date.bump(:wday, 'Mon'), 'every Monday')
    #assert_date_match(@date.bump(:wday, 'Wed'), 'every Wednesday')
    #assert_date_match(@date.bump(:wday, 'Fri'), 'every Friday')
#
    #assert_date_match(Date.new(2021, 2, 1), 'every February', {:start => start, :now => start})
    #assert_date_match(Date.new(2020, 5, 1), 'every May', {:start => start, :now => start})
    #assert_date_match(Date.new(2020, 6, 1), 'every june', {:start => start, :now => start})
#
    #assert_date_match(@date.bump(:wday, 'Sun'), 'beginning of the week')
    #assert_date_match(@date.bump(:wday, 'Wed'), 'middle of the week')
    #assert_date_match(@date.bump(:wday, 'Sat'), 'end of the week')
    end

  end

end

__END__
class TestParsing < Test::Unit::TestCase

  def setup
    Tickle.debug = (ARGV.detect {|a| a == '--d'})
    @verbose = (ARGV.detect {|a| a == '--v'})

    puts "Time.now"
    p Time.now

    @date = Date.today
  end

  def test_parse_best_guess_simple
    start = Date.new(2020, 04, 01)

    assert_date_match(@date.bump(:day, 1), 'each day')
    assert_date_match(@date.bump(:day, 1), 'every day')
    assert_date_match(@date.bump(:week, 1), 'every week')
    assert_date_match(@date.bump(:month, 1), 'every month')
    assert_date_match(@date.bump(:year, 1), 'every year')

    assert_date_match(@date.bump(:day, 1), 'daily')
    assert_date_match(@date.bump(:week, 1) , 'weekly')
    assert_date_match(@date.bump(:month, 1) , 'monthly')
    assert_date_match(@date.bump(:year, 1) , 'yearly')

    assert_date_match(@date.bump(:day, 3), 'every 3 days')
    assert_date_match(@date.bump(:week, 3), 'every 3 weeks')
    assert_date_match(@date.bump(:month, 3), 'every 3 months')
    assert_date_match(@date.bump(:year, 3), 'every 3 years')

    assert_date_match(@date.bump(:day, 2), 'every other day')
    assert_date_match(@date.bump(:week, 2), 'every other week')
    assert_date_match(@date.bump(:month, 2), 'every other month')
    assert_date_match(@date.bump(:year, 2), 'every other year')

    assert_date_match(@date.bump(:wday, 'Mon'), 'every Monday')
    assert_date_match(@date.bump(:wday, 'Wed'), 'every Wednesday')
    assert_date_match(@date.bump(:wday, 'Fri'), 'every Friday')

    assert_date_match(Date.new(2021, 2, 1), 'every February', {:start => start, :now => start})
    assert_date_match(Date.new(2020, 5, 1), 'every May', {:start => start, :now => start})
    assert_date_match(Date.new(2020, 6, 1), 'every june', {:start => start, :now => start})

    assert_date_match(@date.bump(:wday, 'Sun'), 'beginning of the week')
    assert_date_match(@date.bump(:wday, 'Wed'), 'middle of the week')
    assert_date_match(@date.bump(:wday, 'Sat'), 'end of the week')

    assert_date_match(Date.new(2020, 05, 01), 'beginning of the month', {:start => start, :now => start})
    assert_date_match(Date.new(2020, 04, 15), 'middle of the month', {:start => start, :now => start})
    assert_date_match(Date.new(2020, 04, 30), 'end of the month', {:start => start, :now => start})

    assert_date_match(Date.new(2021, 01, 01), 'beginning of the year', {:start => start, :now => start})
    assert_date_match(Date.new(2020, 06, 15), 'middle of the year', {:start => start, :now => start})
    assert_date_match(Date.new(2020, 12, 31), 'end of the year', {:start => start, :now => start})

    assert_date_match(Date.new(2020, 05, 03), 'the 3rd of May', {:start => start, :now => start})
    assert_date_match(Date.new(2021, 02, 03), 'the 3rd of February', {:start => start, :now => start})
    assert_date_match(Date.new(2022, 02, 03), 'the 3rd of February 2022', {:start => start, :now => start})
    assert_date_match(Date.new(2022, 02, 03), 'the 3rd of Feb, 2022', {:start => start, :now => start})

    assert_date_match(Date.new(2020, 04, 04), 'the 4th of the month', {:start => start, :now => start})
    assert_date_match(Date.new(2020, 04, 10), 'the 10th of the month', {:start => start, :now => start})
    assert_date_match(Date.new(2020, 04, 10), 'the tenth of the month', {:start => start, :now => start})

    assert_date_match(Date.new(2020, 05, 01), 'first', {:start => start, :now => start})

    assert_date_match(Date.new(2020, 05, 01), 'the first of the month', {:start => start, :now => start})
    assert_date_match(Date.new(2020, 04, 30), 'the thirtieth', {:start => start, :now => start})
    assert_date_match(Date.new(2020, 04, 05), 'the fifth', {:start => start, :now => start})

    assert_date_match(Date.new(2020, 05, 01), 'the 1st Wednesday of the month', {:start => start, :now => start})
    assert_date_match(Date.new(2020, 05, 17), 'the 3rd Sunday of May', {:start => start, :now => start})
    assert_date_match(Date.new(2020, 04, 19), 'the 3rd Sunday of the month', {:start => start, :now => start})

    assert_date_match(Date.new(2020, 06, 23), 'the 23rd of June', {:start => start, :now => start})
    assert_date_match(Date.new(2020, 06, 23), 'the twenty third of June', {:start => start, :now => start})
    assert_date_match(Date.new(2020, 07, 31), 'the thirty first of July', {:start => start, :now => start})

    assert_date_match(Date.new(2020, 04, 21), 'the twenty first', {:start => start, :now => start})
    assert_date_match(Date.new(2020, 04, 21), 'the twenty first of the month', {:start => start, :now => start})
  end

  def test_parse_best_guess_complex
    start = Date.new(2020, 04, 01)

    assert_tickle_match(@date.bump(:day, 1), @date, @date.bump(:week, 1), 'day', 'starting today and ending one week from now') if Time.now.hour < 21 # => demonstrates leaving out the actual time period and implying it as daily
    assert_tickle_match(@date.bump(:day, 1), @date.bump(:day, 1), @date.bump(:week, 1), 'day','starting tomorrow and ending one week from now') # => demonstrates leaving out the actual time period and implying it as daily.

    assert_tickle_match(@date.bump(:wday, 'Mon'), @date.bump(:wday, 'Mon'), nil, 'month', 'starting Monday repeat every month')

    year = @date >= Date.new(@date.year, 5, 13) ? @date.bump(:year,1) : @date.year
    assert_tickle_match(Date.new(year, 05, 13), Date.new(year, 05, 13), nil, 'week', 'starting May 13th repeat every week')
    assert_tickle_match(Date.new(year, 05, 13), Date.new(year, 05, 13), nil, 'other day', 'starting May 13th repeat every other day')
    assert_tickle_match(Date.new(year, 05, 13), Date.new(year, 05, 13), nil, 'other day', 'every other day starts May 13th')
    assert_tickle_match(Date.new(year, 05, 13), Date.new(year, 05, 13), nil, 'other day', 'every other day starts May 13')
    assert_tickle_match(Date.new(year, 05, 13), Date.new(year, 05, 13), nil, 'other day', 'every other day starting May 13th')
    assert_tickle_match(Date.new(year, 05, 13), Date.new(year, 05, 13), nil, 'other day', 'every other day starting May 13')

    assert_tickle_match(@date.bump(:wday, 'Wed'), @date.bump(:wday, 'Wed'), nil, 'week', 'every week starts this wednesday')
    assert_tickle_match(@date.bump(:wday, 'Wed'), @date.bump(:wday, 'Wed'), nil, 'week', 'every week starting this wednesday')

    assert_tickle_match(Date.new(2021, 05, 01), Date.new(2021, 05, 01), nil, 'other day', "every other day starting May 1st #{start.bump(:year, 1).year}")
    assert_tickle_match(Date.new(2021, 05, 01), Date.new(2021, 05, 01), nil, 'other day',  "every other day starting May 1 #{start.bump(:year, 1).year}")
    assert_tickle_match(@date.bump(:wday, 'Sun'), @date.bump(:wday, 'Sun'),  nil, 'other week',  'every other week starting this Sunday')

    assert_tickle_match(@date.bump(:wday, 'Wed'), @date.bump(:wday, 'Wed'), Date.new(year, 05, 13), 'week', 'every week starting this wednesday until May 13th')
    assert_tickle_match(@date.bump(:wday, 'Wed'), @date.bump(:wday, 'Wed'), Date.new(year, 05, 13), 'week', 'every week starting this wednesday ends May 13th')
    assert_tickle_match(@date.bump(:wday, 'Wed'), @date.bump(:wday, 'Wed'), Date.new(year, 05, 13), 'week', 'every week starting this wednesday ending May 13th')
  end

  def test_tickle_args
    actual_next_only = parse_now('May 1st, 2020', {:next_only => true}).to_date
    assert(Date.new(2020, 05, 01).to_date == actual_next_only, "\"May 1st, 2011\" :next parses to #{actual_next_only} but should be equal to #{Date.new(2020, 05, 01).to_date}")

    start_date = Time.now
    assert_tickle_match(start_date.bump(:day, 3), @date, nil, '3 days', 'every 3 days', {:start => start_date})
    assert_tickle_match(start_date.bump(:week, 3), @date, nil, '3 weeks', 'every 3 weeks', {:start => start_date})
    assert_tickle_match(start_date.bump(:month, 3), @date, nil, '3 months', 'every 3 months', {:start => start_date})
    assert_tickle_match(start_date.bump(:year, 3), @date, nil, '3 years', 'every 3 years', {:start => start_date})

    end_date = Date.civil(Date.today.year, Date.today.month+5, Date.today.day).to_time
    assert_tickle_match(start_date.bump(:day, 3), @date, start_date.bump(:month, 5), '3 days', 'every 3 days', {:start => start_date, :until  => end_date})
    assert_tickle_match(start_date.bump(:week, 3), @date, start_date.bump(:month, 5), '3 weeks', 'every 3 weeks', {:start => start_date, :until  => end_date})
    assert_tickle_match(start_date.bump(:month, 3), @date, start_date.bump(:month, 5), '3 months', 'every 3 months', {:until => end_date})
  end

  def test_us_holidays
    start = Date.new(2020, 01, 01)
    assert_date_match(Date.new(2021, 1, 1), 'New Years Day', {:start => start, :now => start})
    assert_date_match(Date.new(2020, 1, 20), 'Inauguration', {:start => start, :now => start})
    assert_date_match(Date.new(2020, 1, 20), 'Martin Luther King Day', {:start => start, :now => start})
    assert_date_match(Date.new(2020, 1, 20), 'MLK', {:start => start, :now => start})
    assert_date_match(Date.new(2020, 2, 17), 'Presidents Day', {:start => start, :now => start})
    assert_date_match(Date.new(2020, 5, 25), 'Memorial Day', {:start => start, :now => start})
    assert_date_match(Date.new(2020, 7, 4), 'Independence Day', {:start => start, :now => start})
    assert_date_match(Date.new(2020, 9, 7), 'Labor Day', {:start => start, :now => start})
    assert_date_match(Date.new(2020, 10, 12), 'Columbus Day', {:start => start, :now => start})
    assert_date_match(Date.new(2020, 11, 11), 'Veterans Day', {:start => start, :now => start})
    # assert_date_match(Date.new(2020, 11, 26), 'Thanksgiving', {:start => start, :now => start})  # Chronic returning incorrect date.  Routine is correct
    assert_date_match(Date.new(2020, 12, 25), 'Christmas', {:start => start, :now => start})

    assert_date_match(Date.new(2020, 2, 2), 'Super Bowl Sunday', {:start => start, :now => start})
    assert_date_match(Date.new(2020, 2, 2), 'Groundhog Day', {:start => start, :now => start})
    assert_date_match(Date.new(2020, 2, 14), "Valentine's Day", {:start => start, :now => start})
    assert_date_match(Date.new(2020, 3, 17), "Saint Patrick's day", {:start => start, :now => start})
    assert_date_match(Date.new(2020, 4, 1), "April Fools Day", {:start => start, :now => start})
    assert_date_match(Date.new(2020, 4, 22), "Earth Day", {:start => start, :now => start})
    assert_date_match(Date.new(2020, 4, 24), "Arbor Day", {:start => start, :now => start})
    assert_date_match(Date.new(2020, 5, 5), "Cinco De Mayo", {:start => start, :now => start})
    assert_date_match(Date.new(2020, 5, 10), "Mother's Day", {:start => start, :now => start})
    assert_date_match(Date.new(2020, 6, 14), "Flag Day", {:start => start, :now => start})
    assert_date_match(Date.new(2020, 6, 21), "Fathers Day", {:start => start, :now => start})
    assert_date_match(Date.new(2020, 10, 31), "Halloween", {:start => start, :now => start})
    # assert_date_match(Date.new(2020, 11, 10), "Election Day", {:start => start, :now => start}) # Damn Chronic again.  Expression is correct
    assert_date_match(Date.new(2020, 12, 25), 'Christmas Day', {:start => start, :now => start})
    assert_date_match(Date.new(2020, 12, 24), 'Christmas Eve', {:start => start, :now => start})
    assert_date_match(Date.new(2021, 1, 1), 'Kwanzaa', {:start => start, :now => start})

  end

  def test_argument_validation
    assert_raise(Tickle::InvalidArgumentException) do
      time = Tickle.parse("may 27", :today => 'something odd')
    end

    assert_raise(Tickle::InvalidArgumentException) do
      time = Tickle.parse("may 27", :foo => :bar)
    end

    assert_raise(Tickle::InvalidArgumentException) do
      time = Tickle.parse(nil)
    end

    assert_raise(Tickle::InvalidDateExpression) do
      past_date = Date.civil(Date.today.year, Date.today.month, Date.today.day - 1)
      time = Tickle.parse("every other day", {:start => past_date})
    end

    assert_raise(Tickle::InvalidDateExpression) do
      start_date = Date.civil(Date.today.year, Date.today.month, Date.today.day + 10)
      end_date = Date.civil(Date.today.year, Date.today.month, Date.today.day + 5)
      time = Tickle.parse("every other day", :start => start_date, :until => end_date)
    end

    assert_raise(Tickle::InvalidDateExpression) do
      end_date = Date.civil(Date.today.year, Date.today.month+2, Date.today.day)
      parse_now('every 3 months', {:until => end_date})
    end
  end

  private
  def parse_now(string, options={})
    out = Tickle.parse(string, {}.merge(options))
    puts (options.empty? ?  ("Tickle.parse('#{string}')\n\r  #=> #{out}\n\r") : ("Tickle.parse('#{string}', #{options})\n\r  #=> #{out}\n\r")) if @verbose
    out
  end

  def assert_date_match(expected_next, date_expression, options={})
    actual_next = parse_now(date_expression, options)[:next].to_date
    assert (expected_next.to_date == actual_next.to_date), "\"#{date_expression}\" parses to #{actual_next} but should be equal to #{expected_next}"
  end

  def assert_tickle_match(expected_next, expected_start, expected_until, expected_expression, date_expression, options={})
    result = parse_now(date_expression, options)
    actual_next = result[:next].to_date
    actual_start = result[:starting].to_date
    actual_until = result[:until].to_date rescue nil
    expected_until = expected_until.to_date rescue nil
    actual_expression = result[:expression]

    assert (expected_next.to_date == actual_next.to_date), "\"#{date_expression}\" :next parses to #{actual_next} but should be equal to #{expected_next}"
    assert (expected_start.to_date == actual_start.to_date), "\"#{date_expression}\" :starting parses to #{actual_start} but should be equal to #{expected_start}"
    assert (expected_until == actual_until), "\"#{date_expression}\" :until parses to #{actual_until} but should be equal to #{expected_until}"
    assert (expected_expression == actual_expression), "\"#{date_expression}\" :expression parses to \"#{actual_expression}\" but should be equal to \"#{expected_expression}\""
  end

end
