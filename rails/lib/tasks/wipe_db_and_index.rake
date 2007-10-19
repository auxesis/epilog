desc "Drop all tables in the development database"
task :wipe_development_database => :environment do
  puts "Wiping development database" 

  connection = ActiveRecord::Base.connection
    connection.tables.each do |table|
      begin
        connection.execute("drop table #{table}")
        puts "* dropped table '#{table}'"
      rescue
      end
    end

  # legacy hack to simply remove the sqlite db file
  # database_file="#{RAILS_ROOT}/epilog_development"
  # if File.exists?(database_file) then File.delete(database_file) end

end

desc "Deletes the index"
task :wipe_index do
  puts "Wiping ferret index" 
  index_directory="#{RAILS_ROOT}/index"
  if File.exists?(index_directory) then FileUtils.rm_rf(index_directory) end
end

desc "Remove the index, drop all tables, and recreate the database structure"
task :wipe_development_db_and_index do
  # wipe the index and db.
  # this isn't done through dependencies because wiping the database 
  # because you're wiping the index isn't kosher. 
  Rake::Task[:wipe_index].invoke  
  Rake::Task[:wipe_development_database].invoke  

  puts "Recreating the database structure"
  Rake::Task['db:migrate'].invoke  
end
