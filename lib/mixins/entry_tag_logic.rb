module Kerbi
  module Mixins

    ##
    # Mixin for handling mission critical state entry tag logic. The logic
    # is most comprised name resolution, i.e turning special words that users
    # pass in place of literal tags, into literal tags.
    module EntryTagLogic
      extend ActiveSupport::Concern

      SPECIAL_CHAR = "@"

      CANDIDATE_WORD = "candidate"
      NEW_CANDIDATE_WORD = "new-candidate"
      LATEST_WORD = "latest"
      RANDOM_WORD = "random"

      SPECIAL_READ_WORDS = [
        CANDIDATE_WORD,
        LATEST_WORD
      ]

      SPECIAL_WRITE_WORDS = [
        LATEST_WORD,
        CANDIDATE_WORD,
        NEW_CANDIDATE_WORD,
        RANDOM_WORD
      ]

      ##
      # Calls #do_resolve_tag_expr with verb=write in order to turn
      # an entry tag expression like @candidate-new into [cand]purple-forest-new.
      #
      # See documentation for #resolve_word for information on how resolution
      # works at the word level.
      # @param [String] tag_expr
      # @return [String]
      def resolve_write_tag_expr(tag_expr)
        do_resolve_tag_expr(tag_expr, "write")
      end

      ##
      # Calls #do_resolve_tag_expr with verb=read in order to turn
      # an entry tag expression like @latest into 2.1.1
      #
      # See documentation for #resolve_word for information on how resolution
      # works at the word level.
      # @param [String] tag_expr
      # @return [String]
      def resolve_read_tag_expr(tag_expr)
        do_resolve_tag_expr(tag_expr, "read")
      end

      ## Main logic to template state entry tag expressions (that users use
      # to identify state entries with) into a final, usable tag.
      #
      # The method finds special words in the tag expression, which start with
      # the SPECIAL_CHAR '@', and substitutes them one at a time with a computed
      # value. For instance, @latest will become the actual tag of the latest state
      # entry, and @random will become a random string.
      #
      # Depending on whether the user's request is for reading or writing an entry,
      # different substitutions are available.
      # @return [String]
      # @param [String] tag_expr
      # @param [String] verb
      def do_resolve_tag_expr(tag_expr, verb)
        raise "Internal error" unless %w[read write].include?(verb)
        words = verb == 'read' ? SPECIAL_READ_WORDS : SPECIAL_WRITE_WORDS

        resolved_tag = tag_expr
        words.each do |special_word|
          part = "#{SPECIAL_CHAR}#{special_word}"
          if tag_expr.include?(part)
            resolved_word = resolve_word(special_word, verb)
            resolved_tag = resolved_tag.gsub(part, resolved_word)
          end
        end
        resolved_tag
      end

      ##
      # Performs a special word substitution for an individual special word,
      # like 'latest', 'random', or 'candidate'. Works by looking for a
      # corresponding the word-resolver method in self.
      #
      # E.g if you pass 'random', it expects the method resolve_random_word to
      # exist.
      #
      # Because the same special word can have different interpretations
      # depending on whether the mode (read or write), this method will
      # first look for the mode-specialized version of the word-resolver function,
      # e.g if passed 'candidate' in 'read' mode, it will first look out for
      # the a word-resolver method called 'resolve_candidate_read_word' and call it
      # instead of the less specialized 'resolve_candidate_word' method.
      #
      # @param [String] word a special word ('latest', 'random', 'candidate')
      # @param [Object] verb whether this is a read or write operation
      def resolve_word(word, verb)
        word = word.gsub("-", "_")
        if respond_to?((method = "resolve_#{word}_#{verb}_word"))
          send(method)
        elsif respond_to?((method = "resolve_#{word}_word"))
          send(method)
        else
          raise "What is #{word}??"
        end
      end

      ##
      # Single word resolver. Looks for the latest candidate state entry
      # and returns its tag or an empty string if there is no
      # latest candidate state.
      # @return [String]
      def resolve_candidate_read_word
        latest_candidate&.tag || ""
      end

      ##
      # Single word resolver. Outputs a non-taken random tag (given by
      # #generate_random_tag) prefixed with candidate flag prefix [cand]-.
      # @return [String]
      def resolve_candidate_write_word
        resolve_candidate_read_word || resolve_new_candidate_word
      end

      def resolve_new_candidate_word
        prefix = Kerbi::State::Entry::CANDIDATE_PREFIX
        begin
          tag = "#{prefix}#{self.class.generate_random_tag}"
        end while candidates.find{ |e| e.tag == tag }
        tag
      end

      ##
      # Single word resolver. Looks for the latest committed state entry
      # and returns its tag or an empty string if there is no
      # latest committed state.
      # @return [String]
      def resolve_latest_word
        latest&.tag || ""
      end

      ##
      # Single word resolver. Outputs a non-taken random tag (given by
      # #generate_random_tag).
      # @return [String]
      def resolve_random_word
        begin
          tag = self.class.generate_random_tag
        end while entries.find{ |e|e.tag == tag }
        tag
      end

      # private :do_resolve_tag_expr
      # private :resolve_candidate_read_word

      module ClassMethods
        ##
        # Uses the Spicy::Proton gem to generate a convenient,
        # human-readable random tag for a state entry.
        # @return [String]
        def generate_random_tag
          gen = Spicy::Proton.new
          "#{gen.adjective(max: 5)}-#{gen.noun(max: 5)}"
        end
      end

    end
  end
end