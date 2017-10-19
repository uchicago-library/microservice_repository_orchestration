from nginx:1.11.10-alpine

RUN rm /etc/nginx/conf.d/*
COPY proxy.template /etc/nginx/conf.d/
CMD envsubst '$$IPSEITY_INTERNAL_PORT $$REC_API_INTERNAL_PORT $$DEAD_SIMPLE_INTERFACE_INTERNAL_PORT $$ARCHSTOR_INTERNAL_PORT $$QREMIS_API_INTERNAL_PORT $$ACC_IDNEST_INTERNAL_PORT $$LISTEN $$REFRESH $$TIMEOUT $$MAX_FSIZE' < /etc/nginx/conf.d/proxy.template > /etc/nginx/conf.d/proxy.conf && nginx -g 'daemon off;'
