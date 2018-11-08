require 'numerizer'
require_relative "repeater.rb"

module Tickle


  # An extended String
  class Token < String
    attr_accessor :original


    # !@attribute [rw] word Normalized original
    #   @return [String]
    attr_accessor:word
    
    attr_accessor :type, :interval, :start


    # @param [#downcase] original
    # @param [Hash] options
    # @option options [String] :word Normalized original, the implied word
    def initialize(original, options={})
      @original = original
      @word     = options[:word]
      normalize!
      @type     = options[:type]
      @interval = options[:interval]
      @start    = options[:start]
      super @original
    end


    def update!(options={})
      options = {
        :start    =>  nil,
        :interval =>  nil,
      }.merge( options )
      fail ArgumentError, "Token#update! must be passed a 'type'" if options.nil? or options.empty? or not options.has_key?(:type) or options[:type].nil?

      @type = options[:type]
      @start = options[:start]
      @interval = options[:interval]
      self
    end


    COMMON_SYMBOLS = %r{
      (
        [ / \- , @ ]
      )
    }x


    # Clean up the specified input text by stripping unwanted characters,
    # converting idioms to their canonical form, converting number words
    # to numbers (three => 3), and converting ordinal words to numeric
    # ordinals (third => 3rd)
    def normalize!
      @word = Numerizer.numerize(@original.downcase)
                .gsub(/['"\.]/, '')
                .gsub(COMMON_SYMBOLS) {" #{$1} "}
      self
    end
  end


  class Tokens < Array
    include Repeater


    # split into tokens and then
    # process each original word for implied word
    # scan the tokens with each token scanner
    # remove all tokens without a type
    def initialize tokens
      if tokens.respond_to? :split
        words = tokens.split(/\s+/)
        @tokens = words.map {|word| Token.new(word) }
      elsif tokens.respond_to? :map
        if tokens.all? {|token| token.kind_of? Token }
          @tokens = tokens
        else
          @tokens = tokens.map {|token| Token.new(token) }
        end
      else
        fail ArgumentError, "You must pass something that can be tokenized, either a string or an array of strings."
      end
      normalize!
      super @tokens
    end


    def normalize!
      scan!.combine_multiple_numbers
    end


    # Returns an array of types for all tokens
    def types
      map(&:type)
    end


    def by_type
      Hash[ map{|t| [t, t.type] } ]
    end


    def token_of_type(type)
      detect {|token| token.type == type}
    end


      # Turns compound numbers, like 'twenty first' => 21
    def combine_multiple_numbers
      if number = token_of_type(:number)
        num_index = index(number)
        if (ordinal = self[num_index + 1]).type == :ordinal
          combined_original = "#{number.original} #{ordinal.original}"
          combined_word = (number.start.to_s[0] + ordinal.word)
          combined_value = (number.start.to_s[0] + ordinal.start.to_s)
          delete_at num_index + 1
          delete_at num_index
          insert num_index, Token.new(combined_original, word: combined_word, type: :ordinal, start: combined_value, interval: 365)
        end
      end
      self
    end

  end
end