module Kerbi
  module Mixins
    module EntryTagLogic

      SPECIAL_CHAR = "@"

      CANDIDATE_WORD = "candidate"
      LATEST_WORD = "latest"

      SPECIAL_READ_WORDS = [
        CANDIDATE_WORD,
        LATEST_WORD
      ]

      SPECIAL_WRITE_WORDS = %w[
        candidate
        random
      ]

      EXACTLY_CANDIDATE = "#{SPECIAL_CHAR}#{CANDIDATE_WORD}"
      EXACTLY_LATEST = "#{SPECIAL_CHAR}#{LATEST_WORD}"

      def resolve_write_tag(tag_expr)
        resolved_tag = tag_expr
        SPECIAL_WRITE_WORDS.each do |special_word|
          resolved_word = self.resolve_word(special_word, 'write')
          resolved_tag = resolved_tag.gsub(special_word, resolved_word)
        end
        resolved_tag
      end

      def resolve_read_tag(tag_expr)
        resolved_tag = tag_expr
        SPECIAL_READ_WORDS.each do |special_word|
          resolved_word = self.resolve_word(special_word, 'read')
          resolved_tag = resolved_tag.gsub(special_word, resolved_word)
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

      def self.generate_random_tag
        gen = Spicy::Proton.new
        "#{gen.adjective(max: 5)}-#{gen.noun(max: 5)}"
      end

      def exactly_candidate?(tag_expr)
        tag_expr == EXACTLY_CANDIDATE
      end

      def exactly_latest?(tag_expr)
        tag_expr == EXACTLY_CANDIDATE
      end

      # @return [Array<String>]
      def self.illegal_write_special_exprs
        intersection = SPECIAL_READ_WORDS & SPECIAL_WRITE_WORDS
        illegal = SPECIAL_READ_WORDS - intersection
        illegal.map { |word| "#{SPECIAL_CHAR}#{word}" }
      end

      def self.illegal_write_tag_expr?(tag_expr)
        illegal_write_special_exprs.each do |illegal_words|
          return true if tag_expr.include?(illegal_words)
        end
        false
      end
    end
  end
end