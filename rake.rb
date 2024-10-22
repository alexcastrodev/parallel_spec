namespace :parallel_test do
    desc 'Create parallel test database'
    task :prepare => :environment do
        new_databases_name = (ENV['PARALLEL_TEST_GROUPS'] || 2).to_i.times.map do |i|
            "test_#{i}"
        end

        created_databases = []

        begin
            new_databases_name.each do |db_name|
                unless ActiveRecord::Base.connection.execute("SELECT 1 FROM pg_database WHERE datname='#{db_name}'").any?
                    puts "Creating database #{db_name}"
                    ActiveRecord::Base.connection.execute("CREATE DATABASE #{db_name}")
                else
                    puts "Database #{db_name} already exists"
                end

                created_databases << db_name
            end

            # Each new_databases_name will start a process
            new_databases_name.each do |db_name|
                Process.fork do
                    puts "Running migrations on database #{db_name}"
                    db_test_configuration = ActiveRecord::Base.configurations.configurations.find { |c| c.env_name == 'test' }
                    ActiveRecord::Base.establish_connection(db_test_configuration.configuration_hash.merge('database' => db_name))
                    ActiveRecord::MigrationContext.new(Rails.root.join('db', 'migrate'), ActiveRecord::SchemaMigration).migrate
                end
            end

            # We will ensure to run the migrations on the newly created databases
            # new_databases_name.each do |db_name|
            #     puts "Running migrations on database #{db_name}"
            #     db_test_configuration = ActiveRecord::Base.configurations.configurations.find { |c| c.env_name == 'test' }
            #     ActiveRecord::Base.establish_connection(db_test_configuration.configuration_hash.merge('database' => db_name))
            #     ActiveRecord::MigrationContext.new(Rails.root.join('db', 'migrate'), ActiveRecord::SchemaMigration).migrate
            # end
        rescue ActiveRecord::StatementInvalid => e
            puts "Error: #{e}"
        ensure
            # Change to base test database
            ActiveRecord::Base.establish_connection(:test)
            # We will ensure to drop only the databases that were successfully created
            created_databases.each do |db_name|
                puts "Dropping database #{db_name}"
                ActiveRecord::Base.connection.execute("DROP DATABASE IF EXISTS #{db_name}")
            end
        end
    end
end
