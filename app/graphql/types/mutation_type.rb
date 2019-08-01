module Types
  class MutationType < Types::BaseObject
    field :create_service, mutation: Mutations::CreateService
  end
end
