# frozen_string_literal: true

class APIS::APIManagerBase
  private

  def attributes(raw_params)
    raw_params.require(:service).permit(*permitted_params)
    # raw_params.permit(:service).permit(*permitted_params)
  end

  def permitted_params
    [
      :name, :description, :support_email, :deployment_option, :backend_version,
      :intentions_required, :buyers_manage_apps, :referrer_filters_required,
      :buyer_can_select_plan, :buyer_plan_change_permission, :buyers_manage_keys,
      :buyer_key_regenerate_enabled, :mandatory_app_key, :custom_keys_enabled, :state_event,
      :txt_support, :terms,
      {notification_settings: [web_provider: [], email_provider: [], web_buyer: [], email_buyer: []]}
    ]
  end
end
