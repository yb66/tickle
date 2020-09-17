require 'texttube/base'
require_relative "filters.rb"
require 'gitlab-chronic'

module Tickle



  # Contains the initial input and the result of parsing it.
  class Tickled < TextTube::Base
    register Filters

    # @param [String] asked The string Tickle should parse.
    # @param [Hash] options
    # @see Tickle.parse for specific options
    # @see ::Hash#new
    def initialize(asked, options={}, &block)
      fail ArgumentError, "You must pass a string to Tickled.new" if asked.nil?


      default_options = {
        :start      => Time.now,
        :next_only  => false,
        :until      => nil,
        :now        => Time.now,
      }

      unless options.nil? || options.empty?
        # ensure the specified options are valid
        options.keys.each do |key|
          fail(ArgumentError, "#{key} is not a valid option key.") unless default_options.keys.include?(key)
        end

        [:start,:until,:now].each do |key|
          if options.has_key? key
            test_for_correctness options[key], key
          end
        end
      end

      t =
        if asked.respond_to?(:to_time)
          asked
        elsif (t = Time.parse(asked) rescue nil) # a legitimate use!
          t
        elsif (t = Chronic.parse("#{asked}") rescue nil) # another legitimate use!
          t
        end

      unless t.nil?
        define_singleton_method :to_time do
          @as_time ||= t
        end
      end

      @opts = default_options.merge(options)
      super(asked.to_s)
    end


    def asked
      self
    end


    def parser= parser
      @parser = parser
    end

    def parse!
      @parser.parse self
    end

    def now=( value )
      @opts[:now] = value
    end

    def now
      @opts[:now]
    end

    def next_only=( value )
      @opts[:next_only] = value
    end


    def next_only?
      @opts[:next_only]
    end


    # param [Date,Time,String,nil] v The value given for the key.
    # param [Symbol] key The name of the key being tested.
    def test_for_correctness( v, key )
      # Must be be a time or a string or be able to convert to a time
      # If it is a string, must parse ok by Chronic
      fail ArgumentError, "The value (#{v}) given for :#{key} does not appear to be a valid date or time." unless v.respond_to?(:to_time) or (v.respond_to?(:downcase) and ::Chronic.parse(v))
    end


    def asked
      self
    end


    # @param [Date,Time,String]
    def asked=( text )
      #test_for_correctness text, :asked
      @opts[:asked] = text
    end

    def start
      @opts[:start] ||= Time.now
    end

    def start=( value )
      @opts[:start] = test_for_correctness value, :start
    end

    def until
      @opts[:until] ||= Tickled.new( Time.now )
    end

    def until=( value )
      @opts[:until] = test_for_correctness value, :until
    end


    [:starting, :ending, :event].each do |meth|
      define_method meth do
        @opts[meth]
      end
      define_method "#{meth}=" do |value|
        @opts[meth] = Tickled.new value
      end
    end


    def event
      @opts[:event] ||= self
    end
    def event= value
      @opts[:event] = Tickled.new value
    end


    def filtered=(filtered_text)
      @filtered = filtered_text
    end

    def filtered
      @filtered
    end


    def to_s
      self
    end

    def blank?
      if respond_to? :empty?
        empty? || !self
      elsif respond_to? :localtime
        false
      end
    end

#     def inspect
#       "#{self} #{@opts.inspect}"
#     end

  end
end
