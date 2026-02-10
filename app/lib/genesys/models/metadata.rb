module Genesys
  module Models
    class Metadata
      attr_reader :version

      def initialize(metadata_hash)
        @version = metadata_hash['version']
      end

      def to_h
        { 'version' => version }
      end
    end
  end
end
