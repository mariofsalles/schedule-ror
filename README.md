# README

Este README explicará como o app está/foi/será realizado.

Trata-se de um projeto Ruby on Rails realizada a partir do recurso de containerização, utilizando o docker.

Antes de mais nada resolve-se como foi elaborado a sistematica de como realizar o projeto utilizando imagens do dockerfile e docker-compose:

1 - Criação de Dockerfile: 
Criar um arquivo denominado *Dockerfile* com conteudo a seguir, na pasta onde será colocado o projeto RoR:
Notar que a versão do Ruby é esepcificada neste momento como a 2.4.x

    FROM ruby:2.4-jessie
    RUN apt-get update -qq && apt-get install -y nodejs postgresql-client
    RUN mkdir /myapp
    WORKDIR /myapp
    COPY Gemfile /myapp/Gemfile
    COPY Gemfile.lock /myapp/Gemfile.lock
    RUN bundle install
    COPY . /myapp

    # Add a script to be executed every time the container starts.
    COPY entrypoint.sh /usr/bin/
    RUN chmod +x /usr/bin/entrypoint.sh
    ENTRYPOINT ["entrypoint.sh"]
    EXPOSE 3000

    # Start the main process.
    CMD ["rails", "server", "-b", "0.0.0.0"]

2 - Criar e denominar um arquivo *entrypoint.sh* com o seguinte conteudo, na pasta onde será colocado o projeto RoR:

    #!/bin/bash
    set -e

    # Remove a potentially pre-existing server.pid for Rails.
    rm -f /myapp/tmp/pids/server.pid

    # Then exec the container's main process (what's set as CMD in the Dockerfile).
    exec "$@"


3 - Criação do docker-compose: 
Criar um arquivo denominado *docker-compose.yml* com conteudo a seguir, numa pasta onde será colocado o projeto RoR (atenção a identação neste tipo de arquivo):

version: '3'
services:
  adminer:
    image: adminer
    restart: always
    ports:
      - 8080
    depends_on:
      - db
  db:
    image: postgres
    restart: always
    ports:
      - 5432
    env_file:
      - .env
  web:
    build: .
    command: bash -c "rm -f tmp/pids/server.pid && bundle exec rails s -p 3000 -b '0.0.0.0'"
    env_file:
      - .env
    volumes:
      - .:/myapp
    ports:
      - 3000
    depends_on:
      - db

Nota: *adminer, db e web* são serviços que hora ou outra poderá ser invocado para realizar ações nos containers.
Observar também:
    o porque do arquivo Dockerfile, utilizado como o serviço denominado web.
    que o banco de dados é o postgresql e que irá utilizar de variáveis de ambientes para password e senha. Via de regra deverão ser definidos no arquivo esepcificado como .env que possirá como conteudo:
        POSTGRES_USER=postgres
        POSTGRES_PASSWORD=postgres


4 - Criar 2 arquivos denominados *Gemfile e Gemfile.lock* que irão compor o projeto. O arquivo *Gemfile* irá possuir o seguinte conteúdo:

source 'https://rubygems.org'
gem 'rails', '5.1.7'

Utilizar o comando na pasta que estão os arquivos do docker:
    - docker-compose run web rails new . --force --database=postgres
    - docker-compose up --build
    - pronto a aplicação já está iniciada.
