require "sequel"

DB = Sequel.postgres("shrine-crop-example")

Sequel::Model.plugin :timestamps, update_on_create: true
Sequel::Model.plugin :forme
Sequel::Model.plugin :validation_helpers
