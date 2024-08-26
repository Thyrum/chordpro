module Chordpro
  class Environment < Struct.new(:type, :title, :body)
    def initialize(start_directive, body, end_directive)
      super(start_directive.name.to_s.sub("start_of_",""), start_directive.value, body)
    end

    def accept(visitor)
      result = []
      start_type = "start_of_" + type.to_s
      if visitor.respond_to?(start_type)
        result.append(visitor.send(start_type, title))
      else
        result.append(visitor.start_environment(type.to_s, title))
      end
      result.append(body.map { |element| element.accept(visitor) })
      end_type = "end_of_" + type.to_s
      if visitor.respond_to?(end_type)
        result.append(visitor.send(end_type, title))
      elsif visitor.respond_to?("end_environment")
        result.append(visitor.end_environment(type.to_s, title))
      end
      result
    end
  end

  class LyBody < Struct.new(:body)
    def initialize(body)
      super(body)
    end

    def accept(visitor)
      if visitor.respond_to?("ly_body")
        visitor.ly_body(body)
      end
    end
  end

  class ABCBody < Struct.new(:body)
    def initialize(body)
      super(body)
    end

    def accept(visitor)
      if visitor.respond_to?("abc_body")
        visitor.abc_body(body)
      end
    end
  end
end
