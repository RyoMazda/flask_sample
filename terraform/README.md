# 参考
* https://qiita.com/minamijoyo/items/1f57c62bed781ab8f4d7

## ECSのterraform化
* https://christina04.hatenablog.com/entry/2016/07/28/015718

## RDS MySQL Aurora
* https://www.terraform.io/docs/providers/aws/r/rds_cluster.html
* https://nisshiee.hatenablog.jp/entry/2017/04/14/230339


# 質問
* ELB設定すべきか？autoscalingは？
* ssh keyどうdroneで渡すか？
* web socketめんどそう
* DBのpasswordとかどうする？
  - なんかrandomなんちゃらmodule使うらしい
* private subnetにnat繋げなくてRDSは大丈夫か？
  - 大丈夫そう
* ECSのimageをupdateしたときの運用どうすればよい？
  - 現状
    - terraformでecr repository作る
    - 該当git repoのdroneとかにimageをpushするようにする
    - 合わせてaws ecr service update的なのすればよい
  - 問題点
    - 初めecr repoだけ作ってimage pushしてからecsのtf applyしないとerror
    - destroyしたあとapplyするとecrにimageをpushしてない状態でtask defしちゃうので微妙
 * db instanceのendpointをcontainerのdefinitionにうまく使う方法はあるか？


# インフラ構成メモ
* consoleで実験するようがap-northeast-2 (Saul)
* terraform実験用が ap-southeast-1 (Singapore)


## 概要
### WEBサーバー
* ECSで
* port80全公開のpublic subnetにおく

### DB
* RDSで
* Aurora MySQL 5.7.12 (よく知らないけどAurora安いし速いらしい)
* private subnetにおく(上記public subnetからport3306のみでアクセス可)



## ネットワーク準備
* VPCを作る
  - 10.15.0.0/16
  - vpc-0fbf519abd32b7628 | fs
* public subnetを作る
  - 10.15.1.0/24
  - web server 置くため
* Internet Gatewayを作成してvpcにattachする
* route table
  - 作成, vpc紐づけ
  - subnet紐づけ
  - igw紐づけ

## WEBサーバー
### EC2

### ECS
* ECRにimageをpush
* security groupを作る
* cluster作る
* task definition作る
```
{
    "containerDefinitions": [
        {
            "name": "fs-container",
            "image": "000000000000.dkr.ecr.ap-northeast-2.amazonaws.com/flask_sample:latest",
            "memoryReservation": "128",
            "essential": true,
            "portMappings": [
                {
                    "hostPort": "80",
                    "containerPort": "5000",
                    "protocol": "tcp"
                }
            ],
            "environment": null,
            "mountPoints": null,
            "volumesFrom": null,
            "hostname": null,
            "user": null,
            "workingDirectory": null,
            "extraHosts": null,
            "logConfiguration": null,
            "ulimits": null,
            "dockerLabels": null,
            "repositoryCredentials": {
                "credentialsParameter": ""
            }
        }
    ],
    "volumes": [],
    "networkMode": null,
    "memory": "256",
    "cpu": "256",
    "placementConstraints": [],
    "family": "fs-task",
    "taskRoleArn": "arn:aws:iam::00000000000:role/ecsTaskExecutionRole"
}
```
* run task in the cluster or create service
* ipに繋いで確認するべし


## DB
### network
* private subnetを2つ作る
  - 10.15.129.0/24 in the same AZ as public
  - 10.15.130.0/24 in a different AZ as public
* RDS > subnetgroupを作成
-- not yet --
* NAT gatewayをpublic subnetに置く
* route tableをprivate subnet用に作成して送信先をnate gatewayに向ける

### RDS
DB instance identifier: fsdb-instance
Master username: pigimaru
Master password: pigimarupassword
DB cluster identifier: fs-db-cluster
Database name: fsdb
mysql://pigimaru:pigimarupassword@fsdb-instance.cn4g0yxzz6c9.ap-northeast-2.rds.amazonaws.com:3306/fsdb?charset=utf8


