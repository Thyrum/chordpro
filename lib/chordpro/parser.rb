require "parslet"

module Chordpro
  class Parser < Parslet::Parser
    # Characters
    rule(:space) { match('\s').repeat }
    rule(:colon) { space >> str(":") >> space }
    rule(:newline) { str("\n") }
    rule(:lbrace) { str("{") }
    rule(:rbrace) { str("}") }
    rule(:lbracket) { str("[") }
    rule(:rbracket) { str("]") }

    rule(:identifier) { match["a-z"].repeat(1) }
    rule(:start_identifier) { str("so") >> match["a-z"] | str("start_of_") >> identifier }
    rule(:end_identifier) { str("eo") >> match["a-z"] | str("end_of_") >> identifier }

    rule(:value) { (rbrace.absent? >> any).repeat }

    rule(:comment) { str("#") >> (newline.absent? >> any).repeat >> newline.maybe }
    rule(:ly_body) { ((end_ly.absent? >> (any | newline)).repeat).as(:ly_body) }

    rule(:directive) do
      (
        lbrace >> space >>
        str("so").absent? >> str("start_of_").absent? >>
        str("eo").absent? >> str("end_of_").absent? >>
        identifier.as(:name) >>
        (
          colon >> value.as(:value)
        ).maybe >>
        rbrace
      ).as(:directive) >> newline.maybe
    end
    rule(:start_directive) do
      (
        lbrace >> space >> start_identifier.as(:name) >>
        (
          colon >> value.as(:value)
        ).maybe >>
        rbrace
      ).as(:start_directive) >> newline.maybe
    end
    rule(:end_directive) do
      (
        lbrace >> space >> end_identifier.as(:name) >> rbrace
      ).as(:end_directive) >> newline.maybe
    end

    rule(:start_ly) do
      (
        lbrace >> space >> str("start_of_ly").as(:name) >>
        (
          colon >> value.as(:value)
        ).maybe >>
        rbrace
      ).as(:start_directive) >> newline.maybe
    end
    rule(:end_ly) do
      (
        lbrace >> space >> str("end_of_ly").as(:name) >> rbrace
      ).as(:end_directive) >> newline.maybe
    end
    rule(:ly_environment) do
      (
        start_ly.as(:start_environment) >>
        ly_body.as(:ly_body) >>
        end_ly.as(:end_environment)
      ).as(:ly_environment)
    end

    rule(:environment) do
      (
        start_directive.as(:start_environment) >>
        (comment | directive | newline.as(:linebreak) | line).repeat.as(:body) >>
        end_directive.as(:end_environment)
      ).as(:environment)
    end

    rule(:chord) { lbracket >> (rbracket.absent? >> any).repeat.as(:chord) >> rbracket }
    rule(:lyric) { (lbracket.absent? >> newline.absent? >> any).repeat(1).as(:lyric) }
    rule(:line) { lbrace.absent? >> (chord | lyric).repeat(1).as(:line) >> newline.maybe }

    rule(:song) { (ly_environment | environment | comment | directive | newline.as(:linebreak) | line).repeat.as(:song) }

    root(:song)
  end
end
