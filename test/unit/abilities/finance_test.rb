require 'test_helper'

class Abilities::FinanceTest < ActiveSupport::TestCase
  def setup
    @provider = FactoryBot.create(:provider_account)
  end

  test "provider can see finance section if hidden or visible" do
    @provider.settings.allow_finance!
    ability.reload!
    assert_can ability, :see, :finance
    assert_can ability, :admin, :finance

    @provider.settings.show_finance!
    ability.reload!
    assert_can ability, :see, :finance
    assert_can ability, :admin, :finance
  end

  test "if denied, provider can't see the finance section but can administrate it" do
    assert_cannot ability, :see, :finance
    assert_can ability, :admin, :finance
  end

  private

  def ability
    @ability ||= Ability.new(@provider.admin_users.first!)
  end

end
