FROM ruby:2.6.5

WORKDIR /accounts

ENV PORT 80

ENV GEM_HOME /accounts/.gem
ENV PATH $PATH:/accounts/.gem/bin
ENV MONGODB_URL mongodb+srv://virtuatable-accounts:exhAtl1gTYubT8n2@arkaan-xqeoe.mongodb.net/test
ENV SERVICE_URL http://0.0.0.0:80/

COPY . /accounts

CMD bundle install && rackup -p 80 -o 0.0.0.0 --env production