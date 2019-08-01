module Resolvers
  class DefaultApplicationPlan < Resolvers::Base
    type [Types::PlanType], null: true

    def resolve
      self.object.default_application_plan
    end
  end
end