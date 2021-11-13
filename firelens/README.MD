# 1.設定ファイル込みのイメージ作成

同じログ内容を合計 3 箇所の出力先へ送るシンプルな Fluent Bit の設定
=> exra.conf
※予め Kinesis Firehose と S3 は作成しておく

conf に関しては[リンク](https://qiita.com/masalennon/items/2d3241ecd426023ee196)を参考に

# 2.Dockerfile と ECR へイメージアップロード

ECS EC2 の場合、S3 に Fluent Bit の設定ファイルを置いておけば設定ファイルを読み込んでくれる機能がサポートされています。しかし、Fargate はその機能がサポートされていません。そのため、Fluent Bit のコンテナ内に設定ファイルを入れておきます。

AWS Fargate でホストされるタスクは、file 設定ファイルタイプのみをサポートします。

```
$ docker build -t fluentbit-dev-my-firelens .

$ docker tag fluentbit-dev-my-firelens:latest 528163014577.dkr.ecr.us-east-1.amazonaws.com/fluentbit-dev-my-firelens:latest

$ aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 528163014577.dkr.ecr.us-east-1.amazonaws.com

$ docker push 528163014577.dkr.ecr.us-east-1.amazonaws.com/fluentbit-dev-my-firelens:latest
```

# 3.ECS cluster の作成

略

# 4.FireLens 有効化とタスク定義の編集

FireLens 有効
FireLens の統合を有効にチェックを入れます。イメージは ECR にアップした設定ファイル込みの Fluent Bit のイメージを指定します。
有効化すると log_router コンテナが追加されます。

## 1. アプリコンテナ定義の変更

logDriver: awsfirelens

```
"logConfiguration":{
    "logDriver": "awsfirelens",
    "secretOptions": null,
    "options": null
}
```

options が null か、options の項目が存在しないことを確認

## 2. FireLens コンテナ定義の変更

logDriver: awslogs
fluentBit コンテナ自体のトラブル対応のため CloudWatch Logs(awslogs)にログを転送する

```
"logConfiguration":{
    "logDriver": "awslogs",
    "secretOptions": null,
    "options": {
        "awslogs-group": "/ecs/logs/fluentbit-dev-ecs-group",
        "awslogs-region": "us-east-1",
        "awslogs-stream-prefix": "from-log-router"
    }
}
```

## 3. Fluent Bit の設定ファイルの指定

JSON を直接書き換える

```
"firelensConfiguration": {
    "type": "fluentbit",
    "options": {
        "config-file-type": "file",
        "config-file-value": "/fluent-bit/etc/extra.conf"
    }
},
```

## 4. タスクロールの追加

taskexecutionrole ではなく、taskrole にログ送信先のリソースへアクセスできるポリシーを追加
_AmazonS3FullAccess_
_CloudWatchLogsFullAccess_
_AmazonKinesisFirehoseFullAccess_
※先に fluentbit 用の log グループは作成しておく必要があった

# 5.ログ確認

1. Firelens から Cloudwatch ログへ

2. アプリから KinesisFirehose→S3 と S3 へ

FireLens は Fluent Bit または Fluentd を起動するのに便利な機能であって、ログのルーティングは Fluent Bit、Fluentd の設定次第

![アーキテクト](https://cdn-ssl-devio-img.classmethod.jp/wp-content/uploads/2021/02/fargate-fiirelens-fluentbit5.png)
