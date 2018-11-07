module Tickle

  require 'numerizer'
  require_relative "repeater.rb"

  # An extended String
  class Token < ::String
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


    # Split the text on spaces and convert each word into
    # a Token
    # @param [#split] text The text to be tokenized.
    # @return [Array<Token>] The tokens.
    def self.tokenize(text)
      fail ArgumentError unless text.respond_to? :split
      text.split(/\s+/).map { |word| Token.new(word) }
    end


    # Returns an array of types for all tokens
    def self.types(tokens)
      tokens.map(&:type).sort
    end


    def self.token_of_type(type, tokens)
      tokens.detect {|token| token.type == type}
    end


    # @return [Array<Tickle::Token>]
    def self.scan!( tokens )
      fail ArgumentError, "Token#scan must be provided with and Array of Tokens to work with." unless tokens.respond_to? :each
      repeater = Repeater.new tokens
      repeater.scan!
      repeater.tokens
    end

  end
end