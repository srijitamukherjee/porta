# frozen_string_literal: true

class AuthenticationProvidersRepresenter < ThreeScale::CollectionRepresenter
  class JSON < AuthenticationProvidersRepresenter
    include Roar::JSON::Collection
    include ThreeScale::CollectionRepresenter::OrderedCollection
    wraps_resource :authentication_providers
    items extend: AuthenticationProviderRepresenter
  end

  class XML < AuthenticationProvidersRepresenter
    include Roar::XML
    include ThreeScale::CollectionRepresenter::OrderedCollection
    wraps_resource :authentication_providers
    items extend: AuthenticationProviderRepresenter
  end
end
