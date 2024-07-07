#!/bin/sh
# vim:sw=4:ts=4:et

set -e

entrypoint_log() {
    if [ -z "${NGINX_ENTRYPOINT_QUIET_LOGS:-}" ]; then
        echo "$@"
    fi
}

# 環境変数に基づいて nginx.conf を選択
select_nginx_conf() {
    # 大文字小文字を区別せずに比較
    if [ "$(echo $VITE_REACT_APP_IS_BUILD_IMAGE | tr '[:upper:]' '[:lower:]')" = "true" ]; then
        entrypoint_log "Configuring for production environment (run build)"
        cp /etc/nginx/nginx.conf.prod /etc/nginx/nginx.conf
    else
        entrypoint_log "Configuring for development environment (run dev)"
        cp /etc/nginx/nginx.conf.dev /etc/nginx/nginx.conf
    fi
    entrypoint_log "Using nginx configuration:"
    cat /etc/nginx/nginx.conf
}

# nginx.conf の選択を実行
select_nginx_conf

if [ "$1" = "nginx" ] || [ "$1" = "nginx-debug" ]; then
    if /usr/bin/find "/docker-entrypoint.d/" -mindepth 1 -maxdepth 1 -type f -print -quit 2>/dev/null | read v; then
        entrypoint_log "$0: /docker-entrypoint.d/ is not empty, will attempt to perform configuration"
        entrypoint_log "$0: Looking for shell scripts in /docker-entrypoint.d/"
        find "/docker-entrypoint.d/" -follow -type f -print | sort -V | while read -r f; do
            case "$f" in
                *.envsh)
                    if [ -x "$f" ]; then
                        entrypoint_log "$0: Sourcing $f";
                        . "$f"
                    else
                        # warn on shell scripts without exec bit
                        entrypoint_log "$0: Ignoring $f, not executable";
                    fi
                    ;;
                *.sh)
                    if [ -x "$f" ]; then
                        entrypoint_log "$0: Launching $f";
                        "$f"
                    else
                        # warn on shell scripts without exec bit
                        entrypoint_log "$0: Ignoring $f, not executable";
                    fi
                    ;;
                *) entrypoint_log "$0: Ignoring $f";;
            esac
        done
        entrypoint_log "$0: Configuration complete; ready for start up"
    else
        entrypoint_log "$0: No files found in /docker-entrypoint.d/, skipping configuration"
    fi
fi

exec "$@"