FROM ruby:3.3.10

WORKDIR /booker_ruby
ADD Gemfile /booker_ruby
ADD Gemfile.lock /booker_ruby
ADD booker_ruby.gemspec /booker_ruby
ADD lib/booker/version.rb /booker_ruby/lib/booker/version.rb

RUN gem install bundler -v 2.4.22 --no-document
RUN bundle install -j8

ENV DOCKER=true
