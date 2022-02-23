environment "production"

# UNIX Socket縺ｸ縺ｮ繝舌う繝ｳ繝�
tmp_path = "#{File.expand_path("../../..", __FILE__)}/tmp"
bind "unix://#{tmp_path}/sockets/puma.sock"

# 繧ｹ繝ｬ繝�ラ謨ｰ縺ｨWorker謨ｰ縺ｮ謖�ｮ�
threads 3, 3
workers 2
preload_app!

# 繝��繝｢繝ｳ蛹悶�險ｭ螳�
# daemonize
pidfile "#{tmp_path}/pids/puma.pid"
# stdout_redirect "#{tmp_path}/logs/puma.stdout.log", "#{tmp_path}/logs/puma.stderr.log", true

# Allow puma to be restarted by `rails restart` command.
plugin :tmp_restart