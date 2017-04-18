FROM ruby:2.3.3

WORKDIR /booker_ruby
ADD Gemfile /booker_ruby
ADD booker_ruby.gemspec /booker_ruby
ADD lib/booker/version.rb /booker_ruby/lib/booker/version.rb

RUN bundle install -j8

ENV DOCKER=true
