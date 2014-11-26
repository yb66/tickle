module Tickle

  class Token
    attr_accessor :original, :word, :type, :interval, :start


    def initialize(original, word=nil, type=nil, start=nil, interval=nil)
      @original = original
      @word = word
      @type = type
      @interval = interval
      @start = start
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