# frozen_string_literal: true

require 'system/database'

namespace :db do
  task :test => :environment do
    ActiveRecord::Base.establish_connection(:test)
  end

  desc "Loads functions and stored procedures to test database"
  task 'test:procedures' => ['db:test', 'db:procedures']

  procedures = []

  namespace :procedures do
    task :oracle => :environment do
      require 'system/database/definitions/oracle'
      procedures += System::Database::Oracle.procedures
    end

    task :mysql => :environment do
      require 'system/database/definitions/mysql'
      procedures += System::Database::MySQL.procedures
    end

    task :postgres do
      require 'system/database/definitions/postgres'
      procedures += System::Database::Postgres.procedures
    end

    task :load_procedures do
      Rake::Task["db:procedures:#{System::Database.adapter}"].invoke
    end

    task :create => %I[environment load_procedures] do
      procedures.each do |t|
        ActiveRecord::Base.connection.execute(t.create)
      end
    end

    task :drop => %I[environment load_procedures] do
      procedures.each do |t|
        ActiveRecord::Base.connection.execute(t.drop)
      end
    end
  end

  desc 'Recreates the DB procedures (delete+create)'
  task :procedures => %I[environment procedures:load_procedures] do
    puts "Recreating procedures, see log/#{Rails.env}.log"
    procedures.each do |procedure|
      procedure.recreate.each do |command|
        ActiveRecord::Base.connection.execute(command)
      end
    end
    puts "Recreated #{procedures.size} procedures"
  end
end

Rake::Task['db:seed'].enhance(['db:procedures'])
