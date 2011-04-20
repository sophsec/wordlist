require 'rubygems'
require 'rake'

begin
  gem 'ore-tasks', '~> 0.4'
  require 'ore/tasks'

  Ore::Tasks.new
rescue LoadError => e
  warn e.message
  warn "Run `gem install ore-tasks` to install 'ore/tasks'."
end

begin
  gem 'rspec', '~> 2.4'
  require 'rspec/core/rake_task'

  RSpec::Core::RakeTask.new
rescue LoadError => e
  task :spec do
    abort "Please run `gem install rspec` to install RSpec."
  end
end
task :default => :spec

begin
  gem 'yard', '~> 0.6.0'
  require 'yard'

  YARD::Rake::YardocTask.new  
rescue LoadError => e
  task :yard do
    abort "Please run `gem install yard` to install YARD."
  end
end

file 'benchmarks/text/shaks12.txt' do
  require 'net/http'
  require 'uri'

  url = URI('http://www.gutenberg.org/dirs/etext94/shaks12.txt')

  File.open(File.join('benchmarks','text','shaks12.txt'),'w') do |file|
    puts ">>> Downloading shaks12.txt ..."

    Net::HTTP.get_response(url) do |response|
      response.read_body { |chunk| file << chunk }
    end

    puts ">>> Downloaded shaks12.txt."
  end
end

task :benchmarks => 'benchmarks/text/shaks12.txt' do
  ruby File.join('benchmarks/benchmark')
end
