require "bundler/capistrano"
 
set :application, "amazon"
set :user, 'spree'
set :group, 'www-data'
 
set :scm, :git
set :repository,  "git@github.com:spree/amazon_endpoint.git"
set :branch,      "master"
set :deploy_to,   "/data/#{application}"
set :deploy_via,  :remote_cache
set :use_sudo,    false
 
unless exists?(:env)
  set :env, 'staging'
end
 
if env=='production'
  puts "Deploying Production"
  set :rails_env, 'production'
  set :branch, 'master'
 
  role :web, '198.61.170.20'
  role :app, '198.61.170.20'
  role :db,  '198.61.170.20', :primary => true
else
  puts "Deploying Staging"
  set :branch, 'master'
 
  role :web, '198.61.173.119'
  role :app, '198.61.173.119'
  role :db,  '198.61.173.119', :primary => true
end
 
default_run_options[:pty] = true
set :ssh_options, { :forward_agent => true }
set :normalize_asset_timestamps, false
 
namespace :foreman do
  desc "Export the Procfile to Bluepill's .pill script"
  task :export, :roles => :app do
    run "cd #{current_path} && bundle exec foreman export bluepill /data/#{application}/shared/config"
    sudo "bluepill load /data/#{application}/shared/config/#{application}.pill"
  end
 
  desc "Start the application services"
  task :start, :roles => :app do
    sudo "bluepill #{application} start"
  end
 
  desc "Stop the application services"
  task :stop, :roles => :app do
    sudo "bluepill #{application} stop"
  end
 
  desc "Restart the application services"
  task :restart, :roles => :app do
    sudo "bluepill #{application} restart"
  end
end
 
namespace :deploy do
  desc "Symlink shared configs and folders on each release."
  task :symlink_shared do
    run "ln -nfs #{shared_path}/config/Procfile #{release_path}/Procfile"
    run "ln -nfs #{shared_path}/config/.env #{release_path}/.env"
    run "ln -nfs #{shared_path}/config/.foreman #{release_path}/.foreman"
  end
 
  task :migrate do
    puts "No migrations around here."
  end
end
 
before 'deploy:create_symlink', 'deploy:symlink_shared'
 
before 'deploy:start', 'foreman:export'
after 'deploy:start', 'foreman:start'
 
before 'deploy:restart', 'foreman:export'
after 'deploy:restart', 'foreman:restart'