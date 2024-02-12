rm -f /app/tmp/pids/server.pid

cd /app

rails db:create
rails db:migrate

if ! gem list foreman -i --silent; then
  echo "Installing foreman..."
  gem install foreman
fi

foreman start -f Procfile
