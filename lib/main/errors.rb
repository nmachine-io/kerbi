module Kerbi
  class Error < ::StandardError
  end

  class StateBackendNotReadyError < Error
    MSG = "State-keeping backend not ready. Run 'kerbi state status' for more."

    def initialize(msg = MSG)
      super
    end
  end

  class IllegalEntryTag < Error
    def initialize(msg = "State entry tag cannot be 'latest'")
      super
    end
  end

  class IllegalConfigWrite < Error
    LEGAL = Kerbi::Consts::OptionKeys::LEGAL_CONFIG_FILE_KEYS
    def initialize(msg = "Illegal config file assignment. Only #{LEGAL}")
      super
    end
  end

  class BadEntryQueryForWrite < Error
    MSG = "write-state needs an existing entry id/tag, 'candidate', or 'latest'"
    def initialize(msg = MSG)
      super
    end
  end

  class IllegalWriteStateTagWordError < Error
    MSG = "Tag names for writing cannot contain special words exclusive to tag "
    def initialize(msg = MSG)
      super
    end
  end

  class StateNotFoundError < Error
    MSG = "State given by tag not found"
    def initialize(msg = MSG)
      super
    end
  end

  class StateNotPromotable < Error
    MSG = "Non-candidate states cannot be promoted"
    def initialize(msg = MSG)
      super
    end
  end

  class StateNotDemotable < Error
    MSG = "Candidate states cannot be demoted"
    def initialize(msg = MSG)
      super
    end
  end

  class NoSuchStateAttrName < Error
    MSG = "This attribute does not exist or is not writeable"
    def initialize(msg = MSG)
      super(MSG)
    end
  end

  class EntryValidationError < Error
    MSG = "Cannot write state because of validation errors: "

    # @param [Hash] errors
    def initialize(errors)
      message = self.class.build_message(errors)
      super(message)
    end

    # @param [Hash] errors
    def self.error_line(error)
      "#{error[:attr]}['#{error[:value]}']: #{error[:msg]}".indent(1)
    end

    # @param [String] tag
    # @param [Array<Hash>] errors
    def self.entry_line(tag, error_dicts)
      per_tag_parts = error_dicts.map{ |d| error_line(d) }
      "Entry['#{tag}'] \n #{per_tag_parts.join("\n")}".indent(1)
    end

    # @param [Hash] errors
    def self.build_message(errors)
      parts = errors.map { |h| entry_line(h[0], h[1]) }
      "#{MSG} \n#{parts.join("\n")}"
    end
  end

end