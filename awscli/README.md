## ECR へのログイン

```bash
aws ecr get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin <aws id 12>.dkr.ecr.<region>.amazonaws.com
```

## リポジトリ作成

```bash
aws ecr create-repository --repository-name <name/application-name>
```

## ec2 インスタンスに ecr への permission を付与し、(EC2containerServiceEC2Role)

```bash
ecs.config ファイルを作成し s3 に保存、ec2 インスタンスがそれをコピーする(AmazonS3ReadOnlyAccess)
```

## セキュリティグループ作成

```bash
aws ec2 create-security-group --group-name (sg 名) --description "(説明)"
```

## セキュリティグループの確認

```bash
aws ec2 describe-security-groups --group-id sg-(id)
```

## セキュリティグループに rule 追加

```bash
aws ec3 authorize-security-group-ingress --group-id sg-(id) ---protocol tcp --port 22 --cidr 0.0.0.0/0
```

## ecs クラスター

```bash
aws ecs create-cluster --cluster-name (cluster name)
```

## ecs クラスター確認

```bash
aws ecs list-clusters
aws ecs describe-clusters --clusters (cluster 名)
```

## s3 バケット作成

```bash
aws s3api create-bucket --bucket (バケットの名前) --region (リージョン名) --create-bucket-configuration LocationConstraint=(リージョン名)
```

## s3 バケットにファイルを転送

```bash
aws s3 cp (ローカルのファイル名) s3://(バケット名)
```

## s3 の確認

```bash
aws s3 ls s3://(バケット名)
```

## ec2 インスタンスの作成

```bash
aws ec2 run-instances --image-id ami-(id) --count 1 --instance-type t2.micro --iam-instance-profile Name=(role 名) --key-name (key pair 名) --security-group-ids sg-(id) --user-data file://get-config-file-from-s3
```

## ecs クラスターで起動中の ec2 インスタンスを確認

```bash
aws ecs list-container-instances --cluster (クラスター名)
```

## タスク定義作成

```bash
aws ecs register-task-definition --cli-input-json file://(タスク定義用 json ファイル)
```

## タスク確認

```bash
aws ecs list-task-definition-families
```

## サービス作成

```bash
aws ecs create-service --cluster (クラスター名) --service-name (サービス名) --task-definition (タスク定義) --desired-count 1
```

## サービス確認

```bash
aws ecs list-services --cluster (クラスター名)
```

---

```
key pair name - ecs-express-cluster
security group id - sg-0f7d8a694ad7aa25d
AMI (ap-northeast-1) - ami-02898546ea44fc778
IAM instance profile role - ecs-express-role
```

## stop 状態の task リストの表示

```bash
aws ecs list-tasks \
 --cluster ecs-express-cluster \
 --desired-status STOPPED \
 --region ap-northeast-1
```

## task エラーの確認

```bash
aws ecs describe-tasks \
 --cluster ecs-express-cluster \
 --tasks arn:aws:ecs:ap-northeast-1:528163014577:task/ecs-express-cluster/02d06798bf88411a9dd80e42b489284f \
 --region ap-northeast-1
```

```bash
ssh -i "ecs-express-cluster.pem" ec2-user@ec2-54-65-101-111.ap-northeast-1.compute.amazonaws.com
```
