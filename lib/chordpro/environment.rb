module Chordpro
  class Environment < Struct.new(:type, :title, :body)
    def initialize(start_directive, body, end_directive)
      super(start_directive.name.to_s.sub("start_of_",""), start_directive.value, body)
    end

    def accept(visitor)
      result = []
      if visitor.respond_to?(type.to_s)
        result.append(visitor.send(type.to_s, title))
      else
        result.append(visitor.start_environment(type.to_s, title))
      end
      result.append(body.map { |element| element.accept(visitor) })
      end_type = "end_" + type.to_s
      if visitor.respond_to?(end_type)
        result.append(visitor.send(end_type, title))
      elsif visitor.respond_to?("end_environment")
        result.append(visitor.end_environment(type.to_s, title))
      end
      result
    end
  end
end
