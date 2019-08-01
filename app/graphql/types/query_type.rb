module Types
  class QueryType < Types::BaseObject
    field :all_services, [Types::ServiceType], null: false do
      argument :state, String, required: false
    end

    def all_services(state: nil)
      if state != nil
        Service.where({ state: state })
      else
        Service.all
      end
    end

    field :service_by_name, Types::ServiceType, null: false do
      argument :name, String, required: true
    end

    def service_by_name(name:)
      Service.where({ name: name })
    end

    field :service_by_id, Types::ServiceType, null: false do
      argument :id, Int, required: true
    end

    def service_by_id(id:)
      Service.find(id)
    end
  end
end
