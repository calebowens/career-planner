FROM ruby:3.3.0-bookworm

COPY . /app

WORKDIR /app

SHELL ["/bin/bash", "-c"]

RUN apt update -qq && apt upgrade -yqq

RUN bundle config set without test development &&\
  bundle install
RUN env $(cat .env | xargs) rails assets:precompile

EXPOSE 3000

