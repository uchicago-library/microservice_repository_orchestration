from nginx:1.11.10-alpine

RUN rm /etc/nginx/conf.d/*
COPY proxy.template /etc/nginx/conf.d/
CMD envsubst '$$LISTEN $$REFRESH $$UPSTREAM $$TIMEOUT $$MAX_FSIZE' < /etc/nginx/conf.d/proxy.template > /etc/nginx/conf.d/proxy.conf && nginx -g 'daemon off;'
