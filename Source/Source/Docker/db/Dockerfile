FROM mysql:8.0

ENV MYSQL_DATABASE=catermate_db

COPY setup.sql /docker-entrypoint-initdb.d/setup.sql
