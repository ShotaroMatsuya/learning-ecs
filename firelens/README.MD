1.設定ファイル込みのイメージ作成

同じログ内容を合計3箇所の出力先へ送るシンプルなFluent Bitの設定
=>  exra.conf
※予めKinesis FirehoseとS3は作成しておく

confに関しては下記リンクを参考に
https://qiita.com/masalennon/items/2d3241ecd426023ee196

2.DockerfileとECRへイメージアップロード

ECS EC2の場合、S3にFluent Bitの設定ファイルを置いておけば設定ファイルを読み込んでくれる機能がサポートされています。しかし、Fargateはその機能がサポートされていません。そのため、Fluent Bitのコンテナ内に設定ファイルを入れておきます。

AWS Fargate でホストされるタスクは、file 設定ファイルタイプのみをサポートします。

$ docker build -t fluentbit-dev-my-firelens .
$ docker tag fluentbit-dev-my-firelens:latest 528163014577.dkr.ecr.us-east-1.amazonaws.com/fluentbit-dev-my-firelens:latest
$ aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 528163014577.dkr.ecr.us-east-1.amazonaws.com
$ docker push 528163014577.dkr.ecr.us-east-1.amazonaws.com/fluentbit-dev-my-firelens:latest

3.ECS clusterの作成
略

4.FireLens有効化とタスク定義の編集

FireLens有効
FireLensの統合を有効にチェックを入れます。イメージはECRにアップした設定ファイル込みのFluent Bitのイメージを指定します。
有効化するとlog_routerコンテナが追加されます。

①アプリコンテナ定義の変更
logDriver: awsfirelens

"logConfiguration":{
    "logDriver": "awsfirelens",
    "secretOptions": null,
    "options": null
}
optionsがnullか、optionsの項目が存在しないことを確認

②FireLensコンテナ定義の変更
logDriver: awslogs
fluentBitコンテナ自体のトラブル対応のためCloudWatch Logs(awslogs)にログを転送する

"logConfiguration":{
    "logDriver": "awslogs",
    "secretOptions": null,
    "options": {
            "awslogs-group": "/ecs/logs/fluentbit-dev-ecs-group",
            "awslogs-region": "us-east-1",
            "awslogs-stream-prefix": "from-log-router"
        }
}

③Fluent Bitの設定ファイルの指定
JSONを直接書き換える
            "firelensConfiguration": {
                "type": "fluentbit",
                "options": {
                    "config-file-type": "file",
                    "config-file-value": "/fluent-bit/etc/extra.conf"
                }
            },

④タスクロールの追加
taskexecutionroleではなく、taskroleにログ送信先のリソースへアクセスできるポリシーを追加
AmazonS3FullAccess
CloudWatchLogsFullAccess
AmazonKinesisFirehoseFullAccess
※先にfluentbit用のlogグループは作成しておく必要があった

5.ログ確認
①FirelensからCloudwatchログへ
②アプリからKinesisFirehose→S3とS3へ
FireLensはFluent BitまたはFluentdを起動するのに便利な機能であって、ログのルーティングはFluent Bit、Fluentdの設定次第