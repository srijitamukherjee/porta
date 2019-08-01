class Mutations::CreateService < Mutations::BaseMutation
  argument :name, String, required: true

  field :service, Types::ServiceType, null: true
  field :errors, [String], null: false

  def resolve(name:)
    # Using account 2 for simplicity
    service = Account.find(2).services.create(name: name)

    if service.persisted?
      {
        service: service,
        errors: [],
      }
    else
      {
        service: nil,
        errors: service.errors.full_messages
      }
    end
  end
end