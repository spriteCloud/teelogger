# Rubocop
require 'rubocop/rake_task'
RuboCop::RakeTask.new(:rubocop)

# Rspec
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:rspec)

# Combined test task
desc "Test all the things!"
task :test do
  Rake::Task[:rubocop].invoke
  Rake::Task[:rspec].invoke
end

# Default is the test task
task default: :test
