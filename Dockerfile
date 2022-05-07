# Specify a base image
# FROM alpine

# Install some dependencies
# RUN npm install

# Default command
# CMD ["npm","start"]

# エラー1 "npm: not found" :npm installするためのnpmがインストールされていない。そもそもalpineは小規模なdistributionのため、デフォルトでnode.jsやnpmがインストールされていない
# 対策: ベースイメージにalpineがインストールされたnode.jsのイメージを指定する(余計なシステムを読み込まないようにするためversionを14-alpineに設定し、alpine,node.js,npmなどの主要機能のみインストールする)

# FROM node:14-alpine

# RUN npm install

# CMD ["npm","start"]

# エラー2 "npm WARN saveError ENOENT: no such file or directory, open '/package.json'" :dockerコンテナの内部から外部のリソースにアクセスできず、package.jsonファイルが読み取れない
# 対策: コンテナ外のローカルファイルをコンテナ内にコピーする。"COPY 写したいローカルファイルのパス コピー先のdockerコンテナのパス" 

# FROM node:14-alpine

# COPY ./ ./
# RUN npm install

# CMD ["npm","start"]

# docker run imageId or imageName

# エラー3 container内のwebサイトのポート番号にアクセスできない
# 原因: containerはincoming(ユーザーからcontainer)へのアクセスをデフォルトでは許可しない。(outgoing(containerからユーザー、別のサービス)の通信は可能)
# 対策: ユーザーが指定するポートとcontainerのポートを紐づける。containerのポート番号を変える場合は(Node.jsの場合)、index.jsのポート番号を変更する

# docker run -p 外部からアクセスされるポート番号:container内のポート番号 imageId or imageName

# 改善1: "COPY ./ ./"でコピー先をコンテナのルートディレクトリに指定すると、既存のlinuxファイルと行業してしまう可能性がある。
# 対策: dockerfileに処理を指定したディレクトリで行うように設定する。"WORKDIR コンテナのパス"でWORKDIR以下の処理が指定したディレクトリで行われる。
# COPYで指定した2つ目の"./"はWORKDIRを基準にしているため、"/usr/app"ディレクトリを意味する。

# FROM node:14-alpine

# WORKDIR /usr/app

# COPY ./ ./
# RUN npm install

# CMD ["npm","start"]

# 改善2: COPYしたローカルのファイルに変更が生じた場合、コンテナに反映させるために再度build,runする必要がある。2度目のCOPYで変更点を読み込むため、それ以下のRUNフェーズ(npm install)も再読み込みされる。
# 対策: COPYを２つに分ける。あまり変更しないファイル(package.json)を最初に、大きな処理を間に実行し、頻繁に変更するファイル(html,jsファイルなど)を最後にコピーする。ファイルの変更点までCatheで読み込むためスピードが上がる。

FROM node:14-alpine

WORKDIR /usr/app

COPY ./package.json ./
RUN npm install
COPY ./ ./

CMD ["npm","start"]