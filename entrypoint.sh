# #!/bin/bash
# set -e

# # Remove a potentially pre-existing server.pid for Rails.
# rm -f /app/tmp/pids/server.pid

# ruby -v

# # Then exec the container's main process (what's set as CMD in the Dockerfile).
# exec "$@"
#!/bin/bash
set -e

# --- ① whenever の設定をcrontabに反映（失敗しても続行）---
bundle exec whenever --update-crontab || true

# --- ② cron を起動（環境に応じてどれか通る）---
service cron start 2>/dev/null || cron || crond || true

# 既存の処理（PID掃除など）は残す
rm -f /app/tmp/pids/server.pid

ruby -v

# CMD（rails s）を実行
exec "$@"
