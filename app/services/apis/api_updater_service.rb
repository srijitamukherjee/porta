# frozen_string_literal: true

class APIS::APIUpdaterService < APIS::APIManagerBase
  def initialize(service)
    @service = service
  end

  def update(raw_params)
    service.update_attributes(attributes(raw_params))
  end

  private

  attr_reader :service
end
