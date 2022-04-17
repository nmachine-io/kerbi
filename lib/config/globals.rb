module Kerbi
  module Globals
    def self.mixers
      $_mixers ||= []
    end

    def self.reset
      $_mixers = []
    end

    def self.revision=(val)
      $_engine_revision = val
    end

    def self.revision
      $_engine_revision || "0.0.0"
    end
  end
end
