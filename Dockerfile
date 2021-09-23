FROM logstash:7.12.0

# バージョン指定
ARG JDBC_DRIVER_VERSION=SimbaJDBCDriverforGoogleBigQuery42_1.2.14.1017

# 環境変数
ENV HOME /usr/share/logstash
ENV BQ2ES $HOME/bq2es
ENV JDBC_DRIVER $BQ2ES/$JDBC_DRIVER_VERSION
ENV SECRET $BQ2ES/secret
ENV LAST_RUN $BQ2ES/last_run

# JDBCドライバとyumのインストール
USER root
RUN yum install -y \
        "https://packages.endpoint.com/rhel/7/os/x86_64/endpoint-repo-1.7-1.x86_64.rpm" \
        unzip \
        git
RUN mkdir -p $BQ2ES \
    && curl -LO "https://storage.googleapis.com/simba-bq-release/jdbc/${JDBC_DRIVER_VERSION}.zip" \
    && unzip "${JDBC_DRIVER_VERSION}.zip" -d $JDBC_DRIVER \
    && rm "${JDBC_DRIVER_VERSION}.zip"

# 拡張機能のインストール
RUN $HOME/bin/logstash-plugin install \
        logstash-output-exec

# last_runディレクトリの作成
RUN mkdir -p $LAST_RUN && chown logstash:root $LAST_RUN
VOLUME $LAST_RUN

# Elasticsearchの設定ファイルをコピー
COPY --chown=logstash:root ./bq2es/ $BQ2ES/

# パイプライン設定を指定して起動
CMD ["/usr/share/logstash/bin/logstash", "--path.settings", "/usr/share/logstash/bq2es/config/prod"]