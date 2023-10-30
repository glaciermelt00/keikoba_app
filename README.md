## DB Setup

```
// docker の web サーバーに入る
$ docker-compose exec web bash

// DB の作成
root@5ae64ed1e9ae:/keikoba_app# rails db:create

// DB のマイグレーション
root@5ae64ed1e9ae:/keikoba_app# rails db:migrate

// DB のシードデータの投入
root@5ae64ed1e9ae:/keikoba_app# rails db:seed
```
