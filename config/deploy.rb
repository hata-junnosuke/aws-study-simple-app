lock "~> 3.16.0"

set :application, "aws-study-simple-app"
set :repo_url, "git@github.com:hata-junnosuke/aws-study-simple-app.git" # 自身のリモートリポジトリURL
set :user, 'j'
set :deploy_to, "/var/www/aws-study-simple-app"
set :linked_files, %w[config/master.key config/database.yml]
set :linked_dirs, %w[log tmp/pids tmp/cache tmp/sockets public/system vendor/bundle]
set :rbenv_ruby, File.read('.ruby-version').strip
set :puma_threds, [4, 16]
set :puma_workers, 0
set :puma_bind, "unix:///var/www/aws-study-simple-app/shared/tmp/sockets/puma.sock"
set :puma_state, "/var/www/aws-study-simple-app/shared/tmp/pids/puma.state"
set :puma_pid, "/var/www/aws-study-simple-app/shared/tmp/pids/puma.pid"
set :puma_access_log, "/var/www/aws-study-simple-app/shared/log/puma.error.log"
set :puma_error_log, "/var/www/aws-study-simple-app/shared/log/puma.access.log"
set :puma_preload_app, true

namespace :puma do
  desc 'Create Directories for Puma Pids and Socket'
  task :make_dirs do
    on roles(:app) do
      execute "mkdir /var/www/aws-study-simple-app/shared/tmp/sockets -p"
      execute "mkdir /var/www/aws-study-simple-app/shared/tmp/pids -p"
    end
  end

  before :start, :make_dirs
end

namespace :deploy do
  desc 'upload important files'
  task :upload do
    on roles(:app) do
      sudo :mkdir, '-p', "/var/www/aws-study-simple-app/shared/config"
      sudo %[chown -R #{fetch(:user)}.#{fetch(:user)} /var/www/#{fetch(:application)}]
      sudo :mkdir, '-p', '/etc/nginx/sites-enabled'
      sudo :mkdir, '-p', '/etc/nginx/sites-available'

      upload!('config/database.yml', "/var/www/aws-study-simple-app/shared/config/database.yml")
      upload!('config/master.key', "/var/www/aws-study-simple-app/shared/config/master.key")
    end
  end

  desc 'Create database'
  task :db_create do
    on roles(:db) do
      with rails_env: fetch(:rails_env) do
        within release_path do
          execute :bundle, :exec, :rake, 'db:create'
        end
      end
    end
  end

  before :starting, :upload
  before 'check:linked_files', 'puma:nginx_config'
end

after 'deploy:published', 'nginx:restart'
before 'deploy:migrate', 'deploy:db_create'