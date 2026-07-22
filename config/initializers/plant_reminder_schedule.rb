Rails.application.config.after_initialize do
  next if Rails.env.test?
  next unless defined?(SolidQueue::ScheduledExecution)
  next unless defined?(PlantReminderJob)

  if SolidQueue::ScheduledExecution.joins(:job).where(solid_queue_jobs: { class_name: 'PlantReminderJob' }).none?
    Rails.logger.info('[migarden] Scheduling initial PlantReminderJob for next 08:00')
    PlantReminderJob.set(wait_until: PlantReminderJob.next_run_at).perform_later
  end
rescue StandardError => e
  Rails.logger.error("[migarden] Failed to schedule PlantReminderJob: #{e.message}")
end
