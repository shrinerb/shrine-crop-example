namespace :db do
  task :setup do
    require "./config/sequel"
    require "logger"
    Sequel.extension :migration
    DB.logger = Logger.new(STDOUT)
  end

  desc "Run migrations"
  task :migrate, [:version] => :setup do |task, args|
    version = Integer(args[:version]) if args[:version]
    Sequel::Migrator.apply(DB, "db/migrations", version)
  end
end
