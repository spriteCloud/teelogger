# Rubocop
require 'rubocop/rake_task'
RuboCop::RakeTask.new(:rubocop)

# Cucumber
require 'cucumber'
require 'cucumber/rake/task'
Cucumber::Rake::Task.new(:cuke) do |t|
  t.cucumber_opts = "--fail-fast --format=pretty --expand "\
                    "--order=random --backtrace"
end

# Combined test task
desc "Test all the things!"
task :test do
  Rake::Task[:rubocop].invoke
  Rake::Task[:cuke].invoke
end

# Default is the test task
task default: :test
