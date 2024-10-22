# frozen_string_literal: true

require 'parallel'

namespace :parallel_test do
  desc 'Create parallel test database'
  task prepare: :environment do
    new_databases_name = Array.new((ENV['PARALLEL_TEST_GROUPS'] || 4).to_i) do |i|
      "test_#{i}"
    end

    def pretty_print(msg)
      puts Array.new(50) { '=' }.join('')
      puts msg
      log_file(msg)
      puts Array.new(50) { '=' }.join('')
    end

    def log_file(msg)
      File.open('log_spec.txt', 'a') do |f|
        f.puts msg
      end
    end

    created_databases = []
    
    begin
      new_databases_name.each do |db_name|
        ActiveRecord::Base.connection.drop_database(db_name)
        pretty_print("Creating database #{db_name}")
        ActiveRecord::Base.connection.execute("CREATE DATABASE #{db_name}")
        created_databases << db_name
      end

      # Read all spec files and distribute them evenly across databases
      all_spec_files = Dir['spec/**/*_spec.rb']
      start_time = Time.now
      pretty_print("Total spec files to run: #{all_spec_files.size}")

      spec_files_chunks = all_spec_files.each_slice((all_spec_files.size / new_databases_name.size.to_f).ceil).to_a

      # Parallel execution using Parallel gem
      Parallel.each_with_index(new_databases_name, in_processes: new_databases_name.size) do |db_name, index|
        pretty_print("Running migrations on database #{db_name}")
        db_test_configuration = ActiveRecord::Base.configurations.configurations.find { |c| c.env_name == 'test' }
        ActiveRecord::Base.establish_connection(db_test_configuration.configuration_hash.merge('database' => db_name))
        ActiveRecord::MigrationContext.new(Rails.root.join('db', 'migrate')).migrate
        Rake::Task['db:schema:load'].invoke
        Rake::Task['db:seed'].invoke

        spec_files_chunks[index].each do |spec_file|
            Rake::Task['spec'].invoke(spec_file)
        end
      end

      end_time = Time.now
      total_time = end_time - start_time
      pretty_print("All processes finished. Total time taken: #{total_time.round(2)} seconds.")
      
    rescue ActiveRecord::StatementInvalid => e
      pretty_print("Error: #{e}")
      # Change to base test database
      ActiveRecord::Base.establish_connection(:test)
      # Ensure to drop only the databases that were successfully created
      created_databases.each do |db_name|
        pretty_print("Dropping database #{db_name}")
        ActiveRecord::Base.connection.execute("DROP DATABASE IF EXISTS #{db_name}")
      end
    end
  end
end
