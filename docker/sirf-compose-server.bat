@echo off
docker-compose -f docker-compose.yml -f docker-compose.srv.yml %*
