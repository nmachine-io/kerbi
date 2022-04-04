module Kerbi
  module Mixins
    module EntryTagLogic
      extend ActiveSupport::Concern

      SPECIAL_CHAR = "@"
      CANDIDATE_WORD = "candidate"
      LATEST_WORD = "latest"
      RANDOM_WORD = "random"

      SPECIAL_READ_WORDS = [
        CANDIDATE_WORD,
        LATEST_WORD
      ]

      SPECIAL_WRITE_WORDS = [
        CANDIDATE_WORD,
        RANDOM_WORD
      ]

      EXACTLY_CANDIDATE = "#{SPECIAL_CHAR}#{CANDIDATE_WORD}"
      EXACTLY_LATEST = "#{SPECIAL_CHAR}#{LATEST_WORD}"

      def resolve_write_tag(tag_expr)
        resolved_tag = tag_expr
        SPECIAL_WRITE_WORDS.each do |special_word|
          part = "#{SPECIAL_CHAR}#{special_word}"
          if tag_expr.include?(part)
            resolved_word = resolve_word(special_word, 'write')
            resolved_tag = resolved_tag.gsub(part, resolved_word)
          end
        end
        resolved_tag
      end

      def resolve_read_tag(tag_expr)
        resolved_tag = tag_expr
        SPECIAL_READ_WORDS.each do |special_word|
          part = "#{SPECIAL_CHAR}#{special_word}"
          if tag_expr.include?(part)
            resolved_word = resolve_word(special_word, 'read')
            resolved_tag = resolved_tag.gsub(part, resolved_word)
          end
        end
        resolved_tag
      end

      def resolve_word(word, verb)
        if respond_to?((method = "resolve_#{word}_#{verb}_word"))
          send(method)
        elsif respond_to?((method = "resolve_#{word}_word"))
          send(method)
        else
          raise "What is #{word}??"
        end
      end

      def resolve_candidate_read_word
        latest_candidate&.tag || ""
      end

      def resolve_latest_word
        latest&.tag || ""
      end

      def resolve_candidate_write_word
        prefix = Kerbi::State::Entry::CANDIDATE_PREFIX
        begin
          tag = "#{prefix}#{self.class.generate_random_tag}"
        end while candidates.find{ |e|e.tag == tag }
        tag
      end

      def resolve_random_word
        begin
          tag = self.class.generate_random_tag
        end while entries.find{ |e|e.tag == tag }
        tag
      end

      def exactly_candidate?(tag_expr)
        tag_expr == EXACTLY_CANDIDATE
      end

      def exactly_latest?(tag_expr)
        tag_expr == EXACTLY_CANDIDATE
      end

      module ClassMethods

        def generate_random_tag
          gen = Spicy::Proton.new
          "#{gen.adjective(max: 5)}-#{gen.noun(max: 5)}"
        end

        # @return [Array<String>]
        def illegal_write_special_exprs
          intersection = SPECIAL_READ_WORDS & SPECIAL_WRITE_WORDS
          illegal = SPECIAL_READ_WORDS - intersection
          illegal.map { |word| "#{SPECIAL_CHAR}#{word}" }
        end

        def illegal_write_tag_expr?(tag_expr)
          illegal_write_special_exprs.each do |illegal_words|
            return true if tag_expr.include?(illegal_words)
          end
          false
        end
      end

    end
  end
end