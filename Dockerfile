FROM ruby:2.7.6

RUN apt-get update -qq && \
    apt-get install -y build-essential \ 
                       libpq-dev \        
                       nodejs      

RUN mkdir /keikoba_app 

ENV APP_ROOT /keikoba_app 
WORKDIR $APP_ROOT

COPY ./Gemfile $APP_ROOT/Gemfile
COPY ./Gemfile.lock $APP_ROOT/Gemfile.lock

ENV BUNDLER_VERSION 2.4.21
RUN gem install bundler 
RUN bundle install
COPY . $APP_ROOT
