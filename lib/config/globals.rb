module Kerbi
  module Globals
    def self.mixers
      $_mixers ||= []
    end

    def self.reset
      $_mixers = []
    end
  end
end
