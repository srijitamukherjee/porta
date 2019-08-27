namespace :backend_api do
  desc 'Destroy all orphan backend apis that does not belongs to any service when api_as_product is disabled'
  task :destroy_orphans => :environment do
    BackendApi.orphans.each { |b| b.destroy unless b.account.provider_can_use?(:api_as_product) }
  end
end
