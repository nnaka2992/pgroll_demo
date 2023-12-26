# 実行方法
![デモ](demo.gif)
## pgrollをインストールする(必要であれば)
curl -LO https://github.com/xataio/pgroll/releases/download/v0.4.1/pgroll.linux.amd64
mv pgroll.linux.amd64 pgroll
chmod +x pgroll

## コンテナを起動する
### この中で利用しているpostgresコンテナは初期化時にsampleスキーマの作成や、roleの作成を行っている。
docker compose up -d

## pgrollを初期化する
./pgroll init --postgres-url postgres://postgres:postgres@localhost:5432/sample?sslmode=disable

## pgrollでスキーマを作成する
### 末尾のcompleteフラグはpgroll completeをstartと同時に行なう。
./pgroll start ddl/users.json --postgres-url postgres://postgres:postgres@localhost:5432/sample?sslmode=disable --complete

## 作成されたスキーマをアプリケーションから利用する
### アプリケーションはPort 8081と8082で公開されており、どちらも同じPostgreSQLの同じスキーマバージョンを利用している
curl -X POST http://localhost:8081/users/new
curl -X GET http://localhost:8081/users/1

curl -X POST http://localhost:8082/users/new
curl -X GET http://localhost:8082/users/2

## pgrollでDDLを実行する
### このとき先程とは異なりcompleteは実行しない。つまりテーブルスキーマを平行稼動させている。
./pgroll start ddl/users_add_email.json --postgres-url postgres://postgres:postgres@localhost:5432/sample?sslmode=disable

## 平行稼動するスキーマを異なるバージョンのアプリから利用する
### app2をv2にして、
### DB_SEARCH_PATH: "public_users_add_email,public"
### に指しかえる。
vi docker-compose.yaml
docker compose up -d

### 古いバージョン=emailカラムがない
curl -X POST http://localhost:8081/users/new
curl -X GET http://localhost:8081/users/3

### 新しいバージョンはemailがある
curl -X POST http://localhost:8082/users/new
curl -X GET http://localhost:8082/users/4
### 新しいバージョンから古いバージョンのデータを取得すると違いが分かりやすい
curl -X GET http://localhost:8082/users/3

## 次にのこりのアプリのバージョンも新しくする
### app1をv2にして、DB_SEARCH_PATH: "public_users_add_email,public"に指しかえる。
vi docker-compose.yaml

### どっちのendpointからもemailカラムがあるのが分かる
curl -X POST http://localhost:8081/users/new
curl -X GET http://localhost:8081/users/5
curl -X POST http://localhost:8082/users/new
curl -X GET http://localhost:8082/users/6

## pgrollの変更を確定する
## pgroll completeでddlを確定する
./pgroll complete ddl/users_add_email.json --postgres-url postgres://postgres:postgres@localhost:5432/sample?sslmode=disable
