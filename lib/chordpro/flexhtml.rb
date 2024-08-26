require "builder"

module Chordpro
	class FlexHTML
		def initialize(song)
			@song = song
			@html = Builder::XmlMarkup.new
			@body = Builder::XmlMarkup.new
			@environment = @body
			@song.accept(self)
		end

		def add_metadata(metadata)
			head = Builder::XmlMarkup.new
			def missing(metadata, type)
				return metadata[type].nil? || metadata[type].empty?
			end

			def data(metadata, type)
				if missing(metadata, type)
					return nil
				else
					if metadata[type].is_a?(Array)
						return metadata[type].join(", ")
					else
						return metadata[type]
					end
				end
			end

			unless missing(metadata, "title")
				if missing(metadata, "artist")
					head.div(data(metadata, "title"))
				else
					head.div(data(metadata, "title") + " - " + data(metadata, "artist"), class: "title")
				end
			end

			unless missing(metadata, "subtitle")
				head.div(data(metadata, "subtitle"), class: "subtitle")
			end

			@html.div(class: "metadata") do |div|
				div << head.target!
			end
		end

		def to_s
			@html.target!
		end

		def title(title)
		end
		alias_method :t, :title

		def subtitle(subtitle)
		end
		alias_method :st, :subtitle
		alias_method :su, :subtitle

		def line(line, parts)
			chords = []
			lyrics = []

			line.each do |element|
				if element.is_a?(Lyric)
					lyric = element.to_s.squeeze(" ")
					if lyric.start_with? " "
						lyric[0] = "\u00A0"
					end
					if lyric.end_with? " "
						lyric[lyric.size - 1] = "\u00A0"
					end

					# If no chord was provided, enter a nbsp
					unless chords[lyrics.size]
						chords[lyrics.size] = line.parts.size == 1 ? "" : "\u00A0"
					end
					lyrics << lyric
				elsif element.is_a?(Chord)
					chord = element.to_s + "\u00A0\u00A0"
					if chords[lyrics.size]
						chords << chord
						lyrics << ""
					else
						chords[lyrics.size] = chord
					end
				end
			end

			@environment.div(class: "line") do |lineDiv|
				lyrics.size.times do |i|
					lineDiv.div(class: "part") do |partDiv|
						unless chords[i] == ""
							partDiv.div(chords[i], class: "chord")
						end
						partDiv.div(lyrics[i], class: "lyric")
					end
				end
			end
		end

		def linebreak(_)
			@environment.br
		end

		def comment(text)
			@environment.div(text, class: "comment")
		end
		alias_method :c, :comment

		def start_environment(type, title)
			@environment = Builder::XmlMarkup.new
			unless title.nil? || title.empty?
				@environment.div(title, class: "environment-title")
			end
		end

		def end_environment(type, title)
			@body.div(class: "environment #{type}") do |div|
				div << @environment.target!
			end
			@environment = @body
		end

		def ly_body(body)
			@environment.div(class: "lilypond") do |lilyDiv|
				lilyDiv.div(body, class: "code")
			end
		end

		def start_song()
			add_metadata(@song.metadata)
		end

		def end_song()
			@html.div(class: "body") do |html|
				html << @body.target!
			end
		end
	end
end
