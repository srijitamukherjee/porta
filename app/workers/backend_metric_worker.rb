# frozen_string_literal: true

class BackendMetricWorker
  class LockError < StandardError; end

  include Sidekiq::Worker
  include ThreeScale::SidekiqLockWorker
  include ThreeScale::SidekiqRetrySupport::Worker

  sidekiq_options queue: :backend_sync,
                  retry: 3,
                  lock: {
                    timeout: 1.hour.in_milliseconds,
                    name: proc { |*args| BackendMetricWorker.lock_workers(*args) }
                  }
  sidekiq_retry_in do |_count|
    5.minutes.to_i
  end

  def self.lock_workers(service_backend_id, metric_id, *)
    "service:#{service_backend_id}/metric:#{metric_id}"
  end

  def perform(service_backend_id, metric_id, *args)
    retry_job(service_backend_id, metric_id, *args) unless lock(service_backend_id, metric_id).acquire!

    begin
      metric_parent_id = args.size == 4 ? args.last : nil # TODO: Simplify this - We don't really need the system_name being passed among the args
      save_or_delete_metric(service_backend_id, metric_id, metric_parent_id)
    ensure
      lock.release!
    end
  end

  protected

  def retry_job(service_backend_id, metric_id, *args)
    raise LockError if last_attempt?
    self.class.perform_async(service_backend_id, metric_id, *args)
  end

  def save_or_delete_metric(service_backend_id, metric_id, metric_parent_id = nil)
    metric = Metric.find_by(id: metric_id)
    if metric
      save_metric(new_metric_attributes(service_backend_id, metric, metric_parent_id))
    else
      delete_metric(service_backend_id, metric_id)
    end
  end

  def save_metric(attributes = {})
    ThreeScale::Core::Metric.save(attributes)
  end

  def delete_metric(service_backend_id, metric_id)
    ThreeScale::Core::Metric.delete(service_backend_id, metric_id)
  end

  def new_metric_attributes(service_backend_id, metric, metric_parent_id = nil)
    {
      service_id: service_backend_id,
      id: metric.id,
      name: metric.system_name,
      parent_id: metric_parent_id || metric.parent_id
    }
  end
end
