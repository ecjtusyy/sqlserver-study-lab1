#!/usr/bin/env bash
set -e

docker volume create sql2022data >/dev/null 2>&1 || true

docker rm -f sql2022 >/dev/null 2>&1 || true

docker run -e ACCEPT_EULA=Y \
  -e MSSQL_SA_PASSWORD='Aa!23456Bb' \
  -p 1433:1433 \
  --name sql2022 \
  -d \
  -v sql2022data:/var/opt/mssql \
  -v "$PWD/backup":/var/opt/mssql/backup \
  mcr.microsoft.com/mssql/server:2022-latest