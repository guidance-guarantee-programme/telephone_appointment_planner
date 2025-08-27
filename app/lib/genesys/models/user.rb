module Genesys
  module Models
    class User
      attr_reader :id, :self_uri

      def initialize(user_hash)
        @id = user_hash['id']
        @self_uri = user_hash['selfUri']
      end

      def to_h
        { 'userId' => id }
      end
    end
  end
end
