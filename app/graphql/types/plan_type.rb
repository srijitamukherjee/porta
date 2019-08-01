module Types
  class PlanType < Types::BaseObject
    field :name, String, null: false
    field :service, Types::ServiceType, null: false
  end
end
