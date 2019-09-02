# frozen_string_literal: true

class APIS::APIBuilderService < APIS::APIManagerBase
  def initialize(provider)
    @provider = provider
  end

  def build(raw_params)
    provider.services.build(attributes(raw_params))
  end

  def create(raw_params)
    provider.create_service(attributes(raw_params))
  end

  private

  attr_reader :provider

  def permitted_params
    super + [:system_name]
  end
end
