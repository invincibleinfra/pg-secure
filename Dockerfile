FROM postgres:9.6.4-alpine

# docker-entrypoint.sh will drop privileges
# and execute as user 'postgres', but these need to run as root
COPY postgresql.conf /pg-secure/postgresql.conf
RUN chown -R postgres:postgres /pg-secure

# Need to chown the /tls in case it is bind mounted
# when the container is run - postgres requires root/postgres ownership
CMD cp -r /tls /pg-secure/tls && chown -R postgres:postgres /pg-secure/tls && docker-entrypoint.sh postgres --config_file=/pg-secure/postgresql.conf
