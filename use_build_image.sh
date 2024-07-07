#!/bin/bash
set -e

# 環境変数の読み込み
export $(xargs < .env)

REACT_APP_DIR="./front/react-app"
NGINX_HTML_DIR="./nginx/html"

# NGINX_HTML_DIRの所有者とグループを変更
echo "Changing ownership of Nginx html directory..."
sudo chown -R $MY_UID:$MY_GID $NGINX_HTML_DIR

# ビルド成果物のコピー
echo "Copying build artifacts to Nginx html directory..."
rm -rf $NGINX_HTML_DIR/*
cp -r $REACT_APP_DIR/dist/* $NGINX_HTML_DIR/

# Nginxコンテナの再起動
echo "Restarting Nginx container..."
docker compose restart nginx

echo "Process completed successfully."