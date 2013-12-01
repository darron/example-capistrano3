SSHKit.config.command_map[:rake] = "bundle exec rake"

set :application, 'application'
set :github_user, 'darron'
set :github_repo, 'example-capistrano3-template'
set :repo_url, "git@github.com:#{github_user}/#{github_repo}.git"

set :deploy_to, "/home/app/#{application}"
set :scm, :git

set :format, :pretty
set :log_level, :info
# set :pty, true

# set :linked_files, %w{config/database.yml}
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# set :default_env, { path: "/opt/ruby/bin:$PATH" }
set :keep_releases, 5

namespace :setup do

  task :install do
    on roles(:all) do |h|
      execute "curl https://gist.github.com/darron/7609112/raw/32e8938932c757bbcaa04870a910d0b09c126602/ssh_config > ~/.ssh/config "
      execute "git clone git@github.com:#{github_user}/#{github_repo}.git"
      execute "sudo cp -f /home/app/#{github_repo}/config/nginx/config /etc/nginx/sites-available/default"
      execute "sudo cp -f /home/app/#{github_repo}/config/foreman/* /etc/init/"
      execute "rm -rf #{github_repo}"
    end
  end
  
end

namespace :deploy do

    task :start do
      on roles(:all) do |h|
        execute "sudo service #{application} start"
      end
    end

    task :stop do
      on roles(:all) do |h|
        execute "sudo service #{application} stop"
        execute "cd #{deploy_to}/current; bundle exec thin stop -p 5000 -C config/thin.yml"
      end
    end

    task :restart do
      on roles(:all) do |h|
        execute "sudo service #{application} stop"
        execute "cd #{deploy_to}/current; bundle exec thin stop -p 5000 -C config/thin.yml"  
        execute "sudo service #{application} start"
      end
    end
    
    task :logs do
      on roles(:all) do |h|
        execute "cd #{deploy_to}/current; rm -rf log; ln -s /var/log/#{application} log"
      end
    end

  after :finishing, 'deploy:cleanup'
  after :cleanup, 'deploy:logs'
  
end
