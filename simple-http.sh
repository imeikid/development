#!/bin/bash
PORT=$1
while true; do
    echo -e "HTTP/1.1 200 OK\r\nContent-Type: text/html; charset=utf-8\r\nConnection: close\r\n\r\n<html><body><h1>✅ Сервер работает!</h1><p>Порт: $PORT</p><p>Время: $(date)</p></body></html>" | nc -l -p "$PORT" -q 1
done
