from nginx:1.11.10-alpine

RUN rm /etc/nginx/conf.d/*
COPY proxy.template /etc/nginx/conf.d/
ARG UPSTREAM
ARG LISTEN="8080"
ARG REFRESH="10s"
ARG TIMEOUT="30"
ARG MAX_FSIZE="20m"
ENV UPSTREAM=$UPSTREAM
ENV LISTEN=$LISTEN
ENV REFRESH=$REFRESH
ENV TIMEOUT=$TIMEOUT
ENV MAX_FSIZE=$MAX_FSIZE
RUN envsubst '$$LISTEN $$REFRESH $$UPSTREAM $$TIMEOUT $$MAX_FSIZE' < /etc/nginx/conf.d/proxy.template > /etc/nginx/conf.d/proxy.conf
