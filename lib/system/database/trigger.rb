# frozen_string_literal: true

module System
  module Database
    class Trigger
      def initialize(table, trigger)
        @table = table
        @name = "#{table}_tenant_id"
        @trigger = trigger
      end

      attr_reader :name, :table

      def drop
        raise NotImplementedError
      end

      def create
        <<~SQL
          CREATE TRIGGER #{name} BEFORE INSERT ON #{table} FOR EACH ROW #{body}
        SQL
      end

      def recreate
        [drop, create]
      end

      protected

      attr_reader :trigger

      def body
        raise NotImplementedError
      end
    end
  end
end
