FROM ruby:2.7.6

# 必要なパッケージのインストール
RUN apt-get update -qq && \
    apt-get install -y build-essential \ 
                       libpq-dev

# アプリケーションディレクトリの作成
RUN mkdir /keikoba_app 

# 環境変数の設定
ENV APP_ROOT /keikoba_app 
WORKDIR $APP_ROOT

# install nodejs(20.x)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && apt-get install -y nodejs

# install yarn
RUN npm install --global yarn

# GemfileとGemfile.lockをコピー
COPY ./Gemfile $APP_ROOT/Gemfile
COPY ./Gemfile.lock $APP_ROOT/Gemfile.lock

# Bundlerのインストールとbundle installの実行
ENV BUNDLER_VERSION 2.4.21
RUN gem install bundler 
RUN bundle install

# アプリケーションのコードをコピー
COPY . $APP_ROOT
