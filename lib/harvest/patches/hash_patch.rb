module Harvest
  module Patches
    module HashPatch
      def to_params
        to_param
      end
      def self.included(klass)
        klass.send :unloadable
      end
    end
  end
end