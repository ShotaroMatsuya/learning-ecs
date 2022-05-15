# copilot init

→ VPC  
→ pub-subnet x 2 & pri-subnet x 2  
→ IAM role  
→ security group(80,433 port & for container-interactive communication )  
→ internet Gateway to connect to public internet  
→ Route table  
→ ECR repo  
→ ECS Cluster (on fargate)  
→ Application Load Balancer  
→ target group to connect the load balancer  
→ ECS task definition  
→ IAM role for ECS resources

# copilot pipeline init

automatically detected remote origin repository  
create configuration for codebuild & for codepipeline

```bash
git add . & git commit $ git push
```

# copilot pipeline update

→ codePipeline  
→ codeBuild

---

## 手順

1. (アプリケーションの作成)

```bash
   copilot app init (アプリ名)
```

2. (環境の作成)

```bash
   copilot env init (環境名)
```

3. (サービスの作成)

```bash
# 新しく作成する場合
  copilot init
# dockerfile が build されて、ECR が作成され、manifest.yml が作成される
# すでに manifest.yml があると skip されて ECR の作成のみになる。manifest.yml を適用させるために
  copilot svc deploy --name (サービス名) --env (環境名)
```

4. (Environment 作成時に既存の vpc,サブネットをインポート)

```bash
   copilot env init --name (環境名) --region (リージョン名) \
   --import-vpc-id (vpc-xxxxxx) \
   --import-public-subnets subnet-xxxxxx,subnet-xxxxxx \
   --import-private-subnets subnet-xxxxx,subnet-xxxxxx
```

5. (新規で vpc,subnet の作成)

```bash
   copilot env init --name (環境名:prod) --region (リージョン:ap-northeast-1) \
   --override-vpc-cidr 10.1.0.0/16 \
   --override-public-cidrs 10.1.0.0/24,10.1.1.0/24 \
   --override-private-cidrs 10.1.2.0/24,10.1.3.0/24
```

6. (create manifest.yml:defined service)

```bash
   copilot svc init
   (※ecs ごとに新しい service を作成する)
```

7. (update the manifest to change the default)

```bash
   copilot svc deploy --name (サービス名:copilot-cake) --env (環境名:test)
   (既存の task を自動的に削除してくれる!!)
```

8. (すべてのサービスで共有されるパイプラインを作成)

```bash
  copilot pipeline init --url (リポジトリ url) --environments (環境名)
   (init で作成された yml を適用するために)
   copilot pipeline update
```

9. 詳細表示

```bash
   #(サービスの詳細を表示)
   copilot svc show --app (アプリ名) --name (サービス名)
   #(パイプラインの詳細を表示)
   copilot pipeline show --app (アプリ名) --name (パイプライン名) --resources
   #(環境の詳細情報を表示)
   copilot env show --app (アプリ名) --name (環境名) --resources
   #(パイプラインの情報表示)
   copilot pipeline show --app (アプリ名) --resources
```

10. 削除

```bash
    #(サービスの削除)
    copilot svc delete --env (環境名) --name (サービス名)
    #(ワークスペースに紐付いている pipeline の削除)
    copilot pipeline delete --yes
    #(環境の削除)
    copilot env delete --name (環境名) --app (アプリ名)
    #(アプリの削除)
    copilot app delete --yes
    #(パイプラインの削除)
    copilot pipeline delete
```

---

# Concepts

1. Application[chat]
   svc と env を包括する概念  
   最初に application の命名を行うこと

---

2. Environment[test,production]  
    各 environment にはデプロイされたすべての resource 軍を含む  
    Network(VPC,subnet,security group など), ECS クラスタ、ELB、  
    同一 env で Service をデプロイするとそのサービスは同一の ECS クラスタと同一 network で利用できる  
    copilot init すると test Environment を作成するか尋ねられる  
    ネットワークを作成するための必要なリソース(vpc , subnet, security group など)と複数の Service での共有を目的とした Application LoadBalancer や ECS クラスタを含んでいる  
    サービスを Environment にデプロイすることでこれらのネットワークリソースを使用する  
   ---- SSL/TLS ------  
   所有するドメイン名を Route 53 に登録するよう、Application 作成時にオプションとして設定できます。  
    ドメイン名の利用が設定されている場合、Copilot は各 Environment の作成時に environment-name.app-name.your-domain.com のような形でサブドメインを登録し、ACM を通して発行した証明書を  
    Application Load Balancer に設定します。これにより Service が HTTPS を利用できるようになります。  
   RDS 等を使う場合は,environment を作成した際に自動生成される EnvironmentSecurityGroup を inbound rule に追加

---

3. Service [frontend ,api]  
   最初に type を定義[Application Load Balancer]  
   Dockerfile からコンテナ image を作成、ECR リポジトリへ収納  
   Service の設定情報に基づき manifest ファイルを作成  
   最初の copilot init で application 名と service 名を尋ねられる(manifest.yml と空の ECR リポジトリが生成される)  
   ２回目の copilot init で追加する２個目の service 名のみを尋ねられる  
   public サブネットのみで実行され、ロードバランサーを経由したトラフィックのみを受け取る

Load Balanced Web Service タイプで Service が作成されると、同一 Environment 内にデプロイされたすべえての"Load Balanced Web Service"の Service は、Service 固有のリスナーを作成してこの LoadBalancer を共有する。  
ロードバランサーは VPC 内の各 Service と通信できるようにセットアップされる

copilot init コマンド実行時に作成される manifest.yml は Service 用の共通設定や option を含んでいる

copilot svc deploy コマンド  
→Dockerfile から image を local に build  
→git コミットの hash 値で Docker イメージに tag 付け  
→Docker イメージを ECR に push  
→manifest.yml をもとに CloudFormation テンプレートを作成  
→ECS タスクの作成、更新  

