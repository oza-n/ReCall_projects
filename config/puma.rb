# This configuration file will be evaluated by Puma. The top-level methods that
# are invoked here are part of Puma's configuration DSL. For more information
# about methods provided by the DSL, see https://puma.io/puma/Puma/DSL.html.

# Puma can serve each request in a thread from an internal thread pool.
# The `threads` method setting takes two numbers: a minimum and maximum.
# Any libraries that use thread pools should be configured to match
# the maximum value specified for Puma. Default is set to 5 threads for minimum
# and maximum; this matches the default thread size of Active Record.
max_threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
min_threads_count = ENV.fetch("RAILS_MIN_THREADS") { max_threads_count }
threads min_threads_count, max_threads_count

# Specifies the `worker_timeout` threshold that Puma will use to wait before
# terminating a worker in development environments.
worker_timeout 3600 if ENV.fetch("RAILS_ENV", "development") == "development"

# Specifies the `port` that Puma will listen on to receive requests; default is 3000.
port ENV.fetch("PORT") { 3000 }

# Specifies the `environment` that Puma will run in.
environment ENV.fetch("RAILS_ENV") { "development" }

# Specifies the `pidfile` that Puma will use.
pidfile ENV.fetch("PIDFILE") { "tmp/pids/server.pid" }

# 本番環境の設定
if ENV.fetch("RAILS_ENV", "development") == "production"
  # ワーカー数を2に固定(Renderの無料プランに最適)
  workers ENV.fetch("WEB_CONCURRENCY") { 2 }

  # バインドアドレスを明示的に指定
  bind "tcp://0.0.0.0:#{ENV.fetch('PORT')}"

  # プリロードの設定
  preload_app!

  # ワーカー起動時の設定
  on_worker_boot do
    ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
  end
else
  # 開発環境ではbindを使用
  bind "tcp://0.0.0.0:#{ENV.fetch('PORT') { 3000 }}"
end

# Allow puma to be restarted by `bin/rails restart` command.
plugin :tmp_restart
