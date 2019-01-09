class ProxyRulesRepresenter < ThreeScale::CollectionRepresenter
  wraps_resource :mapping_rules

  class JSON < ProxyRulesRepresenter
    include Roar::JSON::Collection
    items extend: ProxyRuleRepresenter::JSON, class: ProxyRule

    def to_json(*args, &block)
      represented.replace(represented.sort_by(&:id)) if System::Database.postgres?
      super(*args, &block)
    end
  end

  class XML < ProxyRulesRepresenter
    include Roar::XML
    wraps_resource :mapping_rules # because including Roar::XML resets the wrap
    items extend: ProxyRuleRepresenter::XML, class: ProxyRule

    def to_xml(*args, &block)
      represented.replace(represented.sort_by(&:id)) if System::Database.postgres?
      super(*args, &block)
    end
  end
end
