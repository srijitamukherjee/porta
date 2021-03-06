require 'test_helper'

class Alerts::LimitAlertReachedBuyerEventTest < ActiveSupport::TestCase

  def test_create
    cinstance = FactoryBot.build_stubbed(:simple_cinstance)
    cinstance.stubs(:provider_account_id).returns(10)
    alert     = FactoryBot.build_stubbed(:limit_alert, id: 2, cinstance: cinstance)
    event     = Alerts::LimitAlertReachedBuyerEvent.create(alert)

    assert event
    assert_equal event.alert, alert
    assert_equal event.provider, cinstance.provider_account
    assert_equal event.service, cinstance.service
  end
end
