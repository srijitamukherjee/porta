# frozen_string_literal: true

module System
  module Database
    module MySQL
      class Trigger < ::System::Database::Trigger
        def drop
          <<~SQL
            DROP TRIGGER IF EXISTS #{name}
          SQL
        end

        def body
          master_id = begin
            Account.master.id
          rescue ActiveRecord::RecordNotFound
            <<~SQL
              (SELECT id FROM accounts WHERE master)
            SQL
          end

          <<~SQL
            BEGIN
              DECLARE master_id numeric;
              IF @disable_triggers IS NULL THEN
                IF NEW.tenant_id IS NULL THEN
                  SET master_id = #{master_id};
                  #{trigger}
                END IF;
              END IF;
            END;
          SQL
        end
      end
    end
  end
end
