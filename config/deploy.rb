set :application, 'amazon'
set :repo_url, 'git@github.com:spree/amazon_endpoint.git'

ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

set :deploy_to, "/data/#{fetch :application}"
set :scm, :git

set :format, :pretty
# set :log_level, :debug
# set :pty, true

# set :linked_files, %w{config/database.yml}
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# set :default_environment, { path: "/opt/ruby/bin:$PATH" }
# set :keep_releases, 5

namespace :deploy do

  desc "Make directories needed in shared configs."
  task :mkdir_shared do
    on roles(:app) do
      execute :mkdir, '-p', "#{shared_path}/{sockets,pids,log}" #unicorn dirs
    end
  end

end

before 'deploy:restart', 'deploy:mkdir_shared'
