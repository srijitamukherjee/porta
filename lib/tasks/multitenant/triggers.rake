# frozen_string_literal: true

require 'system/database'

namespace :multitenant do

  task :test => :environment do
    # ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations['test'])
    ActiveRecord::Base.establish_connection(:test)
  end

  desc "Loads triggers to test database"
  task 'test:triggers' => ['multitenant:test', 'multitenant:triggers']

  namespace :triggers do
    task create: :environment do
      System::Database.triggers.each do |t|
        ActiveRecord::Base.connection.execute(t.create)
      end
    end

    task drop: :environment do
      System::Database.triggers.each do |t|
        ActiveRecord::Base.connection.execute(t.drop)
      end
    end
  end

  desc 'Recreates the DB triggers (delete+create)'
  task triggers: :environment do
    puts "Recreating trigger, see log/#{Rails.env}.log"
    triggers = System::Database.triggers
    triggers.each do |t|
      t.recreate.each do |command|
        ActiveRecord::Base.connection.execute(command)
      end
    end
    puts "Recreated #{triggers.size} triggers"
  end

  desc 'Fix empty or corrupted tenant_id in accounts'
  task :fix_corrupted_tenant_id_accounts, %i[batch_size sleep_time] => :environment do |_task, args|
    batch_size = (args[:batch_size] || 100).to_i
    sleep_time = (args[:sleep_time] || 1).to_i

    ids = [2445582551393, 2445582551394, 2445582551395, 2445582551396, 2445582551397, 2445582574326, 2445582574327,
           2445582574328, 2445582648661, 2445582648665, 2445582648678, 2445582648679, 2445582648680, 2445582680868,
           2445582680869, 2445582680870, 2445582680871, 2445582680872, 2445582680873, 2445582680874, 2445582680875,
           2445582680876, 2445582680877, 2445582680878, 2445582680880, 2445582680881, 2445582680882, 2445582680883,
           2445582680884, 2445582680885, 2445582680886, 2445582680887, 2445582680888, 2445582680889, 2445582680890,
           2445582680891, 2445582680892, 2445582680893, 2445582680894, 2445582680895, 2445582680896, 2445582680897,
           2445582680898, 2445582680899, 2445582680900, 2445582680901, 2445582680902, 2445582680903, 2445582680905,
           2445582680906, 2445582680907, 2445582680908, 2445582680909, 2445582680910, 2445582680911, 2445582680912,
           2445582680913, 2445582680917, 2445582680918, 2445582680926, 2445582680927, 2445582680930, 2445582680931,
           2445582680932, 2445582680933, 2445582680934, 2445582680935, 2445582680936, 2445582680937, 2445582680938,
           2445582680939, 2445582680940, 2445582680941, 2445582680942, 2445582680943, 2445582680944, 2445582680945,
           2445582680948, 2445582680949, 2445582680950, 2445582680951, 2445582680952, 2445582680953, 2445582680954,
           2445582680955, 2445582680956, 2445582680957, 2445582680958, 2445582680959, 2445582680960, 2445582680961,
           2445582680963, 2445582680964, 2445582680965, 2445582680966, 2445582680967, 2445582680968, 2445582680970,
           2445582680971, 2445582680972, 2445582680973, 2445582680974, 2445582680975, 2445582680976, 2445582680977,
           2445582680979, 2445582680980, 2445582680981, 2445582680982, 2445582680983, 2445582680984, 2445582680986,
           2445582680987, 2445582680988, 2445582680989, 2445582680990, 2445582680991, 2445582680992, 2445582680993,
           2445582680994, 2445582680995, 2445582680996, 2445582680997, 2445582680998, 2445582680999, 2445582681000,
           2445582681001, 2445582681002, 2445582681003, 2445582681004, 2445582681007, 2445582681008, 2445582681011,
           2445582681012, 2445582681013, 2445582681014, 2445582681015, 2445582681016, 2445582681017, 2445582681018,
           2445582681019, 2445582681020, 2445582681021, 2445582681022, 2445582681023, 2445582681024, 2445582681025,
           2445582681026, 2445582681027, 2445582681028, 2445582681029, 2445582681030, 2445582681031, 2445582681032,
           2445582681033, 2445582681034, 2445582681035, 2445582681036, 2445582681037, 2445582681038, 2445582681039,
           2445582681040, 2445582681041, 2445582681042, 2445582681044, 2445582681045, 2445582681046, 2445582681047,
           2445582681048, 2445582681049, 2445582681050, 2445582681051, 2445582681053, 2445582681054, 2445582681055,
           2445582681056, 2445582681057, 2445582681058, 2445582681059, 2445582681060, 2445582681061, 2445582681062,
           2445582681063, 2445582681064, 2445582681065, 2445582681066, 2445582681067, 2445582681068, 2445582681080,
           2445582681082, 2445582681083, 2445582681084, 2445582681085, 2445582681086, 2445582681087, 2445582681088,
           2445582681089, 2445582681091, 2445582681092, 2445582681093, 2445582681094, 2445582681095, 2445582681096,
           2445582681097, 2445582681098, 2445582681099, 2445582681101, 2445582681103, 2445582681104, 2445582681107,
           2445582681109, 2445582681110, 2445582681123, 2445582681125, 2445582681126, 2445582681127, 2445582681128,
           2445582681129, 2445582681130]

    id_chunks = []; ids.each_slice(batch_size) { |slice| id_chunks << slice }

    id_chunks.each do |group|
      puts "Executing update for a batch of size: #{group.size}"
      group.each do |id|
        next unless (account = Account.find_by(id: id))
        new_tenant_id = account.buyer? ? account.provider_account_id : account.id
        account.update_column(:tenant_id, new_tenant_id)
      end
      puts "Sleeping #{sleep_time} seconds"
      sleep(sleep_time)
    end
  end

  desc 'Fix empty or corrupted tenant_id in users'
  task :fix_corrupted_tenant_id_users, %i[batch_size sleep_time] => :environment do |_task, args|
    corruption_date = Date.parse('january 24 2019')
    batch_size = (args[:batch_size] || 100).to_i
    sleep_time = (args[:sleep_time] || 1).to_i

    condition = proc { |object| (object.tenant_id == nil) | ((object.created_at >= Time.parse("#{corruption_date} 08:00 UTC").utc) & (object.created_at <= Time.parse("#{corruption_date} 16:30 UTC").utc)) }

    puts '------ Updating "users" ------'
    User.joining { account }.where.has(&condition).find_in_batches(batch_size: batch_size) do |group|
      puts "Executing update for a batch of size: #{group.size}"
      group.each { |user| user.update_column(:tenant_id, user.account.tenant_id) if user.account_id != Account.master.id }
      puts "Sleeping #{sleep_time} seconds"
      sleep(sleep_time)
    end
  end

  desc 'Fix empty or corrupted tenant_id in settings'
  task :fix_corrupted_tenant_id_settings, %i[batch_size sleep_time] => :environment do |_task, args|
    corruption_date = Date.parse('january 24 2019')
    batch_size = (args[:batch_size] || 100).to_i
    sleep_time = (args[:sleep_time] || 1).to_i

    condition = proc { |object| (object.tenant_id == nil) | ((object.created_at >= Time.parse("#{corruption_date} 08:00 UTC").utc) & (object.created_at <= Time.parse("#{corruption_date} 16:30 UTC").utc)) }

    puts '------ Updating "settings" ------'
    Settings.joining { account }.where.has(&condition).find_in_batches(batch_size: batch_size) do |group|
      puts "Executing update for a batch of size: #{group.size}"
      group.each { |settings| settings.update_column(:tenant_id, settings.account.tenant_id) if settings.account_id != Account.master.id }
      puts "Sleeping #{sleep_time} seconds"
      sleep(sleep_time)
    end
  end

  desc 'Fix empty or corrupted tenant_id in profiles'
  task :fix_corrupted_tenant_id_profiles, %i[batch_size sleep_time] => :environment do |_task, args|
    corruption_date = Date.parse('january 24 2019')
    batch_size = (args[:batch_size] || 100).to_i
    sleep_time = (args[:sleep_time] || 1).to_i

    condition = proc { |object| (object.tenant_id == nil) | ((object.created_at >= Time.parse("#{corruption_date} 08:00 UTC").utc) & (object.created_at <= Time.parse("#{corruption_date} 16:30 UTC").utc)) }

    puts '------ Updating "profiles" ------'
    Profile.joining { account }.where.has(&condition).find_in_batches(batch_size: batch_size) do |group|
      puts "Executing update for a batch of size: #{group.size}"
      group.each { |profile| profile.update_column(:tenant_id, profile.account.tenant_id) if profile.account_id != Account.master.id }
      puts "Sleeping #{sleep_time} seconds"
      sleep(sleep_time)
    end
  end

  desc 'Fix empty or corrupted tenant_id in access_tokens'
  task :fix_corrupted_tenant_id_access_tokens, %i[batch_size sleep_time] => :environment do |_task, args|
    batch_size = (args[:batch_size] || 100).to_i
    sleep_time = (args[:sleep_time] || 1).to_i

    puts '------ Updating "access_tokens" ------'
    AccessToken.joining { owner }.where.has { tenant_id == nil }.find_in_batches(batch_size: batch_size) do |group|
      puts "Executing update for a batch of size: #{group.size}"
      group.each do |access_token|
        tenant_id = access_token.owner.tenant_id
        access_token.update_column(:tenant_id, tenant_id) if tenant_id != Account.master.id
      end
      puts "Sleeping #{sleep_time} seconds"
      sleep(sleep_time)
    end
  end

  desc 'Fix empty or corrupted tenant_id in notification_preferences'
  task :fix_corrupted_tenant_id_notification_preferences, %i[batch_size sleep_time] => :environment do |_task, args|
    corruption_date = Date.parse('january 24 2019')
    batch_size = (args[:batch_size] || 100).to_i
    sleep_time = (args[:sleep_time] || 1).to_i

    condition = proc { |object| (object.tenant_id == nil) | ((object.created_at >= Time.parse("#{corruption_date} 08:00 UTC").utc) & (object.created_at <= Time.parse("#{corruption_date} 16:30 UTC").utc)) }

    puts '------Updating "notification_preferences" ------'
    NotificationPreferences.joining { user }.where.has(&condition).find_in_batches(batch_size: batch_size) do |group|
      puts "Executing update for a batch of size: #{group.size}"
      group.each do |notification_preference|
        tenant_id = notification_preference.user.tenant_id
        notification_preference.update_column(:tenant_id, tenant_id) if tenant_id != Account.master.id
      end
      puts "Sleeping #{sleep_time} seconds"
      sleep(sleep_time)
    end
  end

  desc 'Fix empty or corrupted tenant_id in payment_details'
  task :fix_corrupted_tenant_id_payment_details, %i[batch_size sleep_time] => :environment do |_task, args|
    corruption_date = Date.parse('january 24 2019')
    batch_size = (args[:batch_size] || 100).to_i
    sleep_time = (args[:sleep_time] || 1).to_i

    condition = proc { |object| (object.tenant_id == nil) | ((object.created_at >= Time.parse("#{corruption_date} 08:00 UTC").utc) & (object.created_at <= Time.parse("#{corruption_date} 16:30 UTC").utc)) }

    puts '------Updating "payment_details" ------'
    PaymentDetail.joining { account }.where.has(&condition).find_in_batches(batch_size: batch_size) do |group|
      puts "Executing update for a batch of size: #{group.size}"
      group.each { |payment_detail| payment_detail.update_column(:tenant_id, payment_detail.account.tenant_id) if payment_detail.account_id != Account.master.id }
      puts "Sleeping #{sleep_time} seconds"
      sleep(sleep_time)
    end
  end

  desc 'Fix empty or corrupted tenant_id in sso_authorizations'
  task :fix_corrupted_tenant_id_sso_authorizations, %i[batch_size sleep_time] => :environment do |_task, args|
    corruption_date = Date.parse('january 24 2019')
    batch_size = (args[:batch_size] || 100).to_i
    sleep_time = (args[:sleep_time] || 1).to_i

    condition = proc { |object| (object.tenant_id == nil) | ((object.created_at >= Time.parse("#{corruption_date} 08:00 UTC").utc) & (object.created_at <= Time.parse("#{corruption_date} 16:30 UTC").utc)) }

    puts '------Updating "sso_authorizations" ------'
    SSOAuthorization.joining { user }.where.has(&condition).find_in_batches(batch_size: batch_size) do |group|
      puts "Executing update for a batch of size: #{group.size}"
      group.each do |sso_authorization|
        tenant_id = sso_authorization.user.tenant_id
        sso_authorization.update_column(:tenant_id, tenant_id) if tenant_id != Account.master.id
      end
      puts "Sleeping #{sleep_time} seconds"
      sleep(sleep_time)
    end
  end

  desc 'Fix empty or corrupted tenant_id in policies'
  task :fix_corrupted_tenant_id_policies, %i[batch_size sleep_time] => :environment do |_task, args|
    corruption_date = Date.parse('january 24 2019')
    batch_size = (args[:batch_size] || 100).to_i
    sleep_time = (args[:sleep_time] || 1).to_i

    condition = proc { |object| (object.tenant_id == nil) | ((object.created_at >= Time.parse("#{corruption_date} 08:00 UTC").utc) & (object.created_at <= Time.parse("#{corruption_date} 16:30 UTC").utc)) }

    puts '------Updating "policies" ------'
    Policy.joining { account }.where.has(&condition).find_in_batches(batch_size: batch_size) do |group|
      puts "Executing update for a batch of size: #{group.size}"
      group.each { |policy| policy.update_column(:tenant_id, policy.account.tenant_id) if policy.account_id != Account.master.id }
      puts "Sleeping #{sleep_time} seconds"
      sleep(sleep_time)
    end
  end

  desc 'Fix empty or corrupted tenant_id in alerts'
  task :fix_corrupted_tenant_id_alerts, %i[batch_size sleep_time] => :environment do |_task, args|
    batch_size = (args[:batch_size] || 100).to_i
    sleep_time = (args[:sleep_time] || 1).to_i

    puts '------ Updating "alerts" ------'
    Alert.joining { account }.where.has { tenant_id == nil }.find_in_batches(batch_size: batch_size) do |group|
      puts "Executing update for a batch of size: #{group.size}"
      group.each { |alert| alert.update_column(:tenant_id, alert.account.tenant_id) if alert.account_id != Account.master.id }
      puts "Sleeping #{sleep_time} seconds"
      sleep(sleep_time)
    end
  end


  desc 'Fix empty or corrupted tenant_id on all affected tables'
  task :fix_tenant_id, %i[batch_size sleep_time] => :environment do |_task, args|
    batch_size = (args[:batch_size] || 100).to_i
    sleep_time = (args[:sleep_time] || 1).to_i

    %w[accounts users settings profiles access_tokens notification_preferences payment_details sso_authorizations policies alerts].each do |table_name|
      Rake.application.invoke_task("multitenant:fix_corrupted_tenant_id_#{table_name}[#{batch_size}, #{sleep_time}]")
    end
  end

  desc 'Sets the tenant id on all relevant tables'
  task :set_tenant_id => :environment do

    MASTER_ID = Account.master.id

    Account.update_all "tenant_id = provider_account_id WHERE provider <> 1 AND (NOT master OR master IS NULL)"
    Account.update_all "tenant_id = id WHERE provider = 1"
    Alert.update_all "tenant_id = (SELECT tenant_id FROM accounts WHERE id = alerts.account_id AND tenant_id <> #{MASTER_ID})"
    ApiDocs::Service.update_all "tenant_id = account_id WHERE account_id <> #{MASTER_ID}"
    ApplicationKey.update_all "tenant_id = (SELECT tenant_id FROM cinstances WHERE id = application_keys.application_id AND tenant_id <> #{MASTER_ID})"
    Finance::BillingStrategy.update_all "tenant_id = account_id WHERE account_id <> #{MASTER_ID}"
    FieldsDefinition.update_all "tenant_id = account_id WHERE account_id <> #{MASTER_ID}"
    Forum.update_all "tenant_id = account_id WHERE account_id <> #{MASTER_ID}"
    Invoice.update_all "tenant_id = provider_account_id WHERE provider_account_id <> #{MASTER_ID}"
    LineItem.update_all "tenant_id = (SELECT tenant_id FROM invoices WHERE id = line_items.invoice_id AND tenant_id <> #{MASTER_ID})"
    Service.update_all "tenant_id = account_id WHERE account_id <> #{MASTER_ID}"
    Settings.update_all "tenant_id = (SELECT tenant_id FROM accounts WHERE id = settings.account_id AND tenant_id <> #{MASTER_ID})"
    WebHook.update_all "tenant_id = account_id WHERE account_id <> #{MASTER_ID}"
    EndUserPlan.update_all "tenant_id = (SELECT tenant_id FROM services WHERE id = end_user_plans.service_id AND tenant_id <> #{MASTER_ID})"
    Invitation.update_all "tenant_id = (SELECT tenant_id FROM accounts WHERE id = invitations.account_id AND tenant_id <> #{MASTER_ID})"
    MailDispatchRule.update_all "tenant_id = (SELECT tenant_id FROM accounts WHERE id = mail_dispatch_rules.account_id AND tenant_id <> #{MASTER_ID})"
    Message.update_all "tenant_id = (SELECT tenant_id FROM accounts WHERE id = messages.sender_id AND tenant_id <> #{MASTER_ID})"
    MessageRecipient.update_all "tenant_id = (SELECT tenant_id FROM messages WHERE id = message_recipients.message_id AND tenant_id <> #{MASTER_ID})"
    Metric.update_all "tenant_id = (SELECT tenant_id FROM services WHERE id = metrics.service_id AND tenant_id <> #{MASTER_ID})"
    PaymentTransaction.update_all "tenant_id = (SELECT tenant_id FROM invoices WHERE id = payment_transactions.invoice_id AND tenant_id <> #{MASTER_ID})"
    Moderatorship.update_all "tenant_id = (SELECT tenant_id FROM forums WHERE id = moderatorships.forum_id AND tenant_id <> #{MASTER_ID})"
    Post.update_all "tenant_id = (SELECT tenant_id FROM forums WHERE id = posts.forum_id AND tenant_id <> #{MASTER_ID})"
    Profile.update_all "tenant_id = (SELECT tenant_id FROM accounts WHERE id = profiles.account_id AND tenant_id <> #{MASTER_ID})"
    ReferrerFilter.update_all "tenant_id = (SELECT tenant_id FROM cinstances WHERE id = referrer_filters.application_id AND tenant_id <> #{MASTER_ID})"
    TopicCategory.update_all "tenant_id = (SELECT tenant_id FROM forums WHERE id = topic_categories.forum_id AND tenant_id <> #{MASTER_ID})"
    Topic.update_all "tenant_id = (SELECT tenant_id FROM forums WHERE id = topics.forum_id AND tenant_id <> #{MASTER_ID})"
    UsageLimit.update_all "tenant_id = (SELECT tenant_id FROM metrics WHERE id = usage_limits.metric_id AND tenant_id <> #{MASTER_ID})"
    UserTopic.update_all "tenant_id = (SELECT tenant_id FROM topics WHERE id = user_topics.topic_id AND tenant_id <> #{MASTER_ID})"
    User.update_all "tenant_id = (SELECT tenant_id FROM accounts WHERE id = users.account_id AND tenant_id <> #{MASTER_ID})"
    Plan.update_all "tenant_id = issuer_id WHERE type = 'AccountPlan' AND issuer_id <> #{MASTER_ID}"
    Plan.update_all "tenant_id = (SELECT tenant_id FROM services WHERE id = plans.issuer_id AND tenant_id <> #{MASTER_ID}) WHERE type <> 'AccountPlan'"
    PricingRule.update_all "tenant_id = (SELECT tenant_id FROM plans WHERE id = pricing_rules.plan_id AND tenant_id <> #{MASTER_ID})"
    PlanMetric.update_all "tenant_id = (SELECT tenant_id FROM plans WHERE id = plan_metrics.plan_id AND tenant_id <> #{MASTER_ID})"
    Contract.update_all "tenant_id = (SELECT tenant_id FROM plans WHERE id = cinstances.plan_id AND tenant_id <> #{MASTER_ID})"
    Feature.update_all "tenant_id = featurable_id WHERE featurable_type = 'Account' AND featurable_id <> #{MASTER_ID}"
    Feature.update_all "tenant_id = (SELECT tenant_id FROM services WHERE id = features.featurable_id AND tenant_id <> #{MASTER_ID}) WHERE featurable_type <> 'Account'"
    Feature.connection.execute "UPDATE features_plans SET tenant_id = (SELECT tenant_id FROM features WHERE id = features_plans.feature_id AND tenant_id <> #{MASTER_ID})"
    ActiveRecord::Base.connection.execute "UPDATE tags SET tenant_id = account_id WHERE account_id <> #{MASTER_ID}"
    ActiveRecord::Base.connection.execute "UPDATE taggings SET tenant_id = (SELECT tenant_id FROM tags WHERE id = taggings.tag_id AND tenant_id <> #{MASTER_ID})"
    CMS::Section.update_all "tenant_id = provider_id WHERE provider_id <> #{MASTER_ID}"
    CMS::Template.update_all "tenant_id = provider_id WHERE provider_id <> #{MASTER_ID}"
    CMS::Template::Version.update_all "tenant_id = provider_id WHERE provider_id <> #{MASTER_ID}"
    CMS::File.update_all "tenant_id = provider_id WHERE provider_id <> #{MASTER_ID}"
    CMS::Redirect.update_all "tenant_id = provider_id WHERE provider_id <> #{MASTER_ID}"
    CMS::Group.update_all "tenant_id = provider_id WHERE provider_id <> #{MASTER_ID}"
    CMS::Section.update_all "tenant_id = provider_id WHERE provider_id <> #{MASTER_ID}"
    CMS::Permission.update_all "tenant_id = (SELECT tenant_id FROM cms_groups WHERE cms_groups.id = group_id)"
    CMS::GroupSection.update_all "tenant_id = (SELECT tenant_id FROM cms_groups WHERE cms_groups.id = group_id)"
    MemberPermission.update_all "tenant_id = (SELECT tenant_id FROM users WHERE id = user_id)"
    LogEntry.update_all "tenant_id = provider_id WHERE provider_id <> #{MASTER_ID}"

    Proxy.update_all "tenant_id = (SELECT tenant_id FROM services WHERE id = proxies.service_id AND tenant_id <> #{MASTER_ID})"
    ProxyRule.update_all "tenant_id = (SELECT tenant_id FROM proxies WHERE id = proxy_rules.proxy_id AND tenant_id <> #{MASTER_ID})"

    AccessToken.update_all "tenant_id = (SELECT tenant_id FROM users WHERE users.id = access_tokens.owner_id AND tenant_id <> #{MASTER_ID})"
    EventStore::Event.update_all "tenant_id = provider_id WHERE provider_id <> #{MASTER_ID}"
    GoLiveState.update_all "tenant_id = account_id WHERE account_id <> #{MASTER_ID}"
    NotificationPreferences.update_all "tenant_id = (SELECT tenant_id FROM users WHERE id = user_id AND tenant_id <> #{MASTER_ID})"
    Onboarding.update_all "tenant_id = account_id WHERE account_id <> #{MASTER_ID}"
    PaymentDetail.update_all "tenant_id = (SELECT tenant_id FROM accounts WHERE id = account_id AND tenant_id <> #{MASTER_ID})"
    PaymentGatewaySetting.update_all "tenant_id = account_id WHERE account_id <> #{MASTER_ID}"
    ServiceToken.update_all "tenant_id = (SELECT tenant_id FROM services WHERE id = service_id AND tenant_id <> #{MASTER_ID})"
    SSOAuthorization.update_all "tenant_id = (SELECT tenant_id FROM users WHERE id = user_id AND tenant_id <> #{MASTER_ID})"
    ProvidedAccessToken.update_all "tenant_id = account_id WHERE account_id <> #{MASTER_ID}"
    Policy.update_all "tenant_id = (SELECT tenant_id FROM accounts WHERE id = policies.account_id AND tenant_id <> #{MASTER_ID})"

    # FIXME: This will not work when we have more than 1 oidc_configurable_type
    OIDConfiguration.update_all "tenant_id = (SELECT tenant_id FROM proxies WHERE id = oidc_configurable_id AND tenant_id <> #{MASTER_ID})"
  end
end

task 'db:triggers' => 'multitenant:triggers' # Alias for 'multitenant:triggers'. TODO: Move the task to the 'db' namespace and refactor so a trigger can be defined not only for setting the tenant_id
Rake::Task['db:seed'].enhance(['multitenant:triggers'])
