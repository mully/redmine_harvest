module Harvest
  module Patches
    module HashPatch
      def to_params
        to_param
      end
      def self.included(klass)
        # jk: this leads to Hash being undefined after the first request in dev
        # mode...
        # klass.send :unloadable
      end
    end
  end
end
