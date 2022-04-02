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
end