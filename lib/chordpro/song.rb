module Chordpro
  class Song
    attr_reader :elements, :metadata

    def initialize(elements = [])
      @elements = elements
      @metadata = Metadata.new(@elements)
    end

    def accept(visitor)
      if visitor.respond_to?(:start_song)
        visitor.start_song()
      end
      elements.map { |element| element.accept(visitor) }
      if visitor.respond_to?(:end_song)
        visitor.end_song()
      end
    end

    def method_missing(method, *args)
      if respond_to_missing?(method)
        metadata[method]
      else
        super
      end
    end

    def respond_to_missing?(method, include_all = false)
      super || !!Directive.find(method)&.meta
    end
  end
end
