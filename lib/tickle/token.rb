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



    # Returns an array of types for all tokens
    def self.types(tokens)
      tokens.map(&:type)
    end


    def self.token_of_type(type, tokens)
      tokens.detect {|token| token.type == type}
    end

  end
end