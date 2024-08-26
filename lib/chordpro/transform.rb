module Chordpro
  class Transform < Parslet::Transform
    %i[directive start_directive end_directive].each do |directive|
      rule(directive => {name: simple(:name), value: simple(:value)}) do
        directive_name = Directive.find(name) || Directive::Name.new(name.to_s)
        Chordpro::Directive.new(directive_name, value.to_s)
      end

      rule(directive => {name: simple(:name), value: []}) do
        directive_name = Directive.find(name) || Directive::Name.new(name.to_s)
        Chordpro::Directive.new(directive_name, "")
      end

      rule(directive => {name: simple(:name)}) do
        directive_name = Directive.find(name) || Directive::Name.new(name.to_s)
        Chordpro::Directive.new(directive_name)
      end
    end

    rule(ly_body: simple(:ly_body)) { Chordpro::LyBody.new(ly_body.to_s) }
    rule(ly_environment: {
      start_environment: simple(:start_environment),
      ly_body: simple(:ly_body),
      end_environment: simple(:end_environment)
    }) do
      print ly_body
      Chordpro::Environment.new(start_environment, [ly_body], end_environment)
    end

    rule(environment: {
        start_environment: simple(:start_environment),
        body: subtree(:body),
        end_environment: simple(:end_environment)
    }) do
      Chordpro::Environment.new(start_environment, body, end_environment)
    end


    rule(linebreak: simple(:x)) { Chordpro::Linebreak.new }
    rule(chord: simple(:name)) { Chordpro::Chord.new(name.to_s) }
    rule(lyric: simple(:text)) { Chordpro::Lyric.new(text.to_s) }
    rule(line: subtree(:parts)) { Chordpro::Line.new(parts) }
    rule(song: subtree(:elements)) { Chordpro::Song.new(elements) }
  end
end
