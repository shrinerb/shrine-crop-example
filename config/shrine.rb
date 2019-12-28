require "shrine"
require "shrine/storage/file_system"
require "dry/monitor"

require "./jobs/promote_job"
require "./jobs/destroy_job"

Shrine.storages = {
  cache: Shrine::Storage::FileSystem.new("public", prefix: "uploads/cache"),
  store: Shrine::Storage::FileSystem.new("public", prefix: "uploads"),
}

Shrine.plugin :sequel
Shrine.plugin :cached_attachment_data

Shrine.plugin :determine_mime_type, analyzer: :marcel

Shrine.plugin :restore_cached_data
Shrine.plugin :validation_helpers
Shrine.plugin :default_url

Shrine.plugin :instrumentation,
  notifications: Dry::Monitor::Notifications.new(:test),
  log_events:    []

Shrine.plugin :derivatives
Shrine.plugin :derivation_endpoint, secret_key: "secret"

Shrine.plugin :upload_endpoint, url: true

Shrine.plugin :backgrounding
Shrine::Attacher.promote_block do
  PromoteJob.perform_async(self.class.name, record.class.name, record.id, name, file_data)
end
Shrine::Attacher.destroy_block do
  DestroyJob.perform_async(self.class.name, data)
end
