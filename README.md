# bigquery2elasticsearch-sync

## 設定

1. JDBCドライバのバージョンを指定してください。
デフォルトでは、`SimbaJDBCDriverforGoogleBigQuery42_1.2.14.1017`を使用しています。最新バージョンは以下から確認できます。
[BigQuery 用の ODBC ドライバと JDBC ドライバ](https://cloud.google.com/bigquery/docs/reference/odbc-jdbc-drivers)

2. `bq2essecret/service-account-key.json`にBigQueryにアクセスするためのサービスアカウントの鍵をペーストしてください。

3. `bq2es/config`以下にあるElasticsearchの設定ファイルを変更してください。変更すべき部分は、大文字になっています（環境変数以外のEXAMPLE-GCP-PROJECTやEXAMPLE-ESなど）。

4. `cloudbuild.yml`の設定を変更してください。

## テスト実行

`bq2es.conf`の実行

```shell
$ echo -e '--- 0\n' > ${LAST_RUN}/.test.logstash_jdbc_last_run && ${HOME}/bin/logstash -f ${BQ2ES}/config/test/bq2es/bq2es.conf
```

`check-es.conf`の実行

```shell
$ ${HOME}/bin/logstash -f ${BQ2ES}/config/test/check-es/check-es.conf
```

## GCPでのイメージのビルドとプッシュ
`$ gcloud builds submit --config cloudbuild.yml .`

## データ同期のためのクエリ
```SQL
SELECT
    *
FROM
    `EXAMPLE-PROJECT.EXAMPLE-DATASET.EXAMPLE-TABLE`
WHERE
    UNIX_SECONDS(modified) > :sql_last_value
    AND modified < CURRENT_TIMESTAMP()
```

以下の記事を参考にしています。

[LogstashおよびJDBCを使用してElasticsearchとリレーショナルデータベースの同期を維持する方法](https://www.elastic.co/jp/blog/how-to-keep-elasticsearch-synchronized-with-a-relational-database-using-logstash)