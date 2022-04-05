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

end