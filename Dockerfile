FROM docker.m.daocloud.io/library/node:20 AS builder

WORKDIR /metube
COPY ui/package*.json ./

# 设置 npm 镜像源并安装依赖
RUN npm config set registry https://registry.npmmirror.com \
    && npm install -g @angular/cli \
    && npm install

# 复制源代码
COPY ui ./

# 构建项目
RUN ng build --configuration production


FROM docker.m.daocloud.io/library/python:3.11-alpine

WORKDIR /app

COPY Pipfile* docker-entrypoint.sh ./

RUN sed -i 's/\r$//g' docker-entrypoint.sh && \
    chmod +x docker-entrypoint.sh && \
    apk add --update ffmpeg aria2 coreutils shadow su-exec curl && \
    apk add --update --virtual .build-deps gcc g++ musl-dev && \
    pip install --no-cache-dir pipenv && \
    pipenv install --system --deploy --clear && \
    pip uninstall pipenv -y && \
    apk del .build-deps && \
    rm -rf /var/cache/apk/* && \
    mkdir /.cache && chmod 777 /.cache

COPY app ./app
COPY --from=builder /metube/dist/metube ./ui/dist/metube

ENV UID=10000 \
    GID=10000 \
    UMASK=022 \
    DOWNLOAD_DIR=/downloads \
    STATE_DIR=/downloads/.metube \
    TEMP_DIR=/downloads

VOLUME /downloads
EXPOSE 5001
CMD [ "./docker-entrypoint.sh" ]
