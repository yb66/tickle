require 'chronic'

module Tickle


  # Contains the initial input and the result of parsing it.
  class Tickled < ::Hash

    # @param [String] asked The string Tickle should parse.
    # @param [Hash] options
    # @see Tickle.parse for specific options
    # @see ::Hash#new
    def initialize(asked, options=nil, &block)
      # get options and set defaults if necessary.
      self[:start]      = Time.now
      self[:next_only]  = false
      self[:until]      = nil
      self[:now]        = Time.now
      self.asked        = asked # trigger checks during assignment

      unless options.nil? || options.empty?
        # ensure the specified options are valid
        options.keys.each do |key|
          fail(ArgumentError, "#{key} is not a valid option key.") unless self.keys.include?(key)
        end

        [:start,:until,:now].each do |key|
          if options.has_key? key
            test_for_correctness options[key], key
          end
        end

        merge!(options)
      end
      super()
    end


    def parser= parser
      @parser = parser
    end

    def parse!
      @parser.parse self
    end

    def now=( value )
      self[:now] = value
    end

    def now
      self[:now]
    end

    def next_only=( value )
      self[:next_only] = value
    end


    def next_only?
      self[:next_only]
    end


    # param [Date,Time,String,nil] v The value given for the key.
    # param [Symbol] key The name of the key being tested.
    def test_for_correctness( v, key )
      # Must be be a time or a string or be able to convert to a time
      # If it is a string, must parse ok by Chronic
      throw :invalid_date_expression, "The value (#{v}) given for :#{key} does not appear to be a valid date or time." unless v.respond_to?(:to_time) or (v.respond_to?(:downcase) and ::Chronic.parse(v))
    end


    def asked
      self[:asked]
    end


    # @param [Date,Time,String]
    def asked=( text )
      test_for_correctness text, :asked
      self[:asked] = text
    end

    def start
      self[:start] ||= Time.now
    end

    def start=( value )
      self[:start] = test_for_correctness value, :start
    end

    def until
      self[:until] ||= Time.now
    end

    def until=( value )
      self[:until] = test_for_correctness value, :until
    end



    [:starting, :ending, :event].each do |meth|
      define_method meth do
        self[meth]
      end
      define_method "#{meth}=" do |value|
        self[meth] = value
      end
    end
  end
end
