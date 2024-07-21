#

## サブモジュールを持つリポジトリの更新

GitHubにpushする前にサブモジュールの更新とマージを完了させ

- git checkout develop
- git fetch --prune --recurse-submodules
- git submodule update --remote --merge

## Reactのrun buildで生成される静的イメージをnginxコンテナにdocker-compose.ymlで一括で送り込むことはできない

- reactのdistフォルダに静的イメージができるまでの時間が長く、docker-compose.ymでそれを待って、permissionエラーを回避しながらnginxコンテナを起動させようとするとdocker-compose.yml、関連するDockerfile、シェルスクリプトが大変複雑になる。
- frontを run dev / run buildの切り替えは環境変数　VITE_REACT_APP_IS_BUILD_IMAGE　で切り替える。Falseは run dev。Trueはrun build。
- docker-compose.ymlはroot:rootで実行されるため、volumesを使うとローカルにroot:rootのフォルダやファイルが作られる。そのフォルダはyarn initの権限が合わず、permissionエラーになることがある。
- 静的イメージをコピーしnginxコンテナを再起動するシェルスクリプトuse_build_image.shを使用する。
  
  - VITE_REACT_APP_IS_BUILD_IMAGE = Trueにする。
  - docker-compose.ymlの上にマウスカーソルを持っていき、右クリック→ Compose Up
  - クジラのアイコンをクリックしてDockerコンテナの動作画面に移動し、reactコンテナの上にマウスカーソルを持っていき、View Logsをクリック
  - reactコンテナの生成を見ながら、distに静的イメージが出来るのを待つ。
  - use_build_image.shの上にマウスカーソルを置き、右クリック→Open in Integrated Terminal
  - ./use_build_image.shを実行。reactの静的イメージがnginx/htmlにコピーされ、nginxコンテナが再起動。
