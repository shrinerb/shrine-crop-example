require "sucker_punch"

class PromoteJob
  include SuckerPunch::Job

  def perform(attacher_class, record_class, record_id, name, file_data)
    attacher_class = Object.const_get(attacher_class)
    record         = Object.const_get(record_class).with_pk!(record_id)

    attacher = attacher_class.retrieve(model: record, name: name, file: file_data)
    attacher.create_derivatives
    attacher.atomic_promote
  rescue Shrine::AttachmentChanged, Sequel::NoExistingObject, Sequel::NoMatchingRow
  end
end
