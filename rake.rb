# frozen_string_literal: true

namespace :parallel_test do
    desc 'Create parallel test database'
    task prepare: :environment do
      new_databases_name = Array.new((ENV['PARALLEL_TEST_GROUPS'] || 2).to_i) do |i|
        "test_#{i}"
      end
  
      def pretty_print(msg)
        puts 50.times.map { '=' }.join('')
        puts msg
        puts 50.times.map { '=' }.join('')
      end
  
      created_databases = []
      child_pids = []
  
      # Capture Ctrl+C (SIGINT) signal to ensure clean shutdown
      Signal.trap('INT') do
        pretty_print 'Caught interrupt signal, cleaning up...'
  
        # Kill all forked child processes
        child_pids.each do |pid|
          begin
            pretty_print "Killing process #{pid}"
            Process.kill('TERM', pid)
          rescue Errno::ESRCH
            # Process has already been terminated
            pretty_print "Process #{pid} not found."
          end
        end
  
        # Drop the databases if they were created
        created_databases.each do |db_name|
          pretty_print "Dropping database #{db_name} from TRAP"
          ActiveRecord::Base.connection.execute("DROP DATABASE IF EXISTS #{db_name}")
        end
  
        # Exit the script
        exit(1)
      end
  
      begin
        new_databases_name.each do |db_name|
          if ActiveRecord::Base.connection.execute("SELECT 1 FROM pg_database WHERE datname='#{db_name}'").any?
            pretty_print "Database #{db_name} already exists"
          else
            pretty_print "Creating database #{db_name}"
            ActiveRecord::Base.connection.execute("CREATE DATABASE #{db_name}")
          end
  
          created_databases << db_name
        end
  
        # Read spec files
        queue_spec_files = Dir['spec/**/*_spec.rb']
        start_time = Time.now
  
        # Each new_databases_name will start a process
        new_databases_name.each do |db_name|
          child_pid = Process.fork do
            pretty_print "Running migrations on database #{db_name}"
            db_test_configuration = ActiveRecord::Base.configurations.configurations.find { |c| c.env_name == 'test' }
            ActiveRecord::Base.establish_connection(db_test_configuration.configuration_hash.merge('database' => db_name))
            ActiveRecord::MigrationContext.new(Rails.root.join('db', 'migrate')).migrate
            Rake::Task['db:schema:load'].invoke
  
            until queue_spec_files.empty?
              # Pop and get the first spec file
              spec_file = queue_spec_files.pop
              pretty_print "Running spec file #{spec_file} on database #{db_name}"
              # Run the spec file
              system("bundle exec rspec #{spec_file}")
            end
          end
  
          child_pids << child_pid
        end
  
        # Wait for all child processes to finish
        child_pids.each do |pid|
          Process.wait(pid)
        end
  
        end_time = Time.now
        total_time = end_time - start_time
        pretty_print "All processes finished. Total time taken: #{total_time.round(2)} seconds."
  
      rescue ActiveRecord::StatementInvalid => e
        pretty_print "Error: #{e}"
        # Change to base test database
        ActiveRecord::Base.establish_connection(:test)
        # We will ensure to drop only the databases that were successfully created
        created_databases.each do |db_name|
          pretty_print "Dropping database #{db_name}"
          ActiveRecord::Base.connection.execute("DROP DATABASE IF EXISTS #{db_name}")
        end
      end
    end
  end
  
