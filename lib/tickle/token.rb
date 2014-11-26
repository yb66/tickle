module Tickle

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


    # Updates an existing token.  Mostly used by the repeater class.
    def update(type, start=nil, interval=nil)
      @start = start
      @type = type
      @interval = interval
    end



    # Returns an array of types for all tokens
    def self.types(tokens)
      tokens.map(&:type)
    end


    def self.token_of_type(type, tokens)
      tokens.detect {|token| token.type == type}
    end

  end
end