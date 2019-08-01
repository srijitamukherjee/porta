module Types
  class ServiceType < Types::BaseObject
    field :name, String, null: false
    field :created_at, String, null: false
    field :state, String, null: true
    field :default_application_plan, Types::PlanType, null: true, resolver: Resolvers::DefaultApplicationPlan
    field :plans, [Types::PlanType], null: false
  end
end
