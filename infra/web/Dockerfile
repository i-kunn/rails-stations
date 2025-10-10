# FROM ruby:3.3.3
# RUN apt-get update -qq
# RUN apt-get install --no-install-recommends -y build-essential git libvips pkg-config nodejs npm && npm install n -g && n lts
# RUN npm install -g yarn
# RUN mkdir /app
# WORKDIR /app

# # このDockerfileでgemのインストールやyarnによるパッケージのインストールをしていないのは、
# # ログインなどの処理を挟む必要があるため。
# COPY Gemfile /app/Gemfile
# COPY Gemfile.lock /app/Gemfile.lock
# COPY . /app

# COPY entrypoint.sh /usr/bin/
# RUN chmod +x /usr/bin/entrypoint.sh
# ENTRYPOINT ["entrypoint.sh"]
# EXPOSE 3000

# CMD ["rails", "server", "-b", "0.0.0.0"]
FROM ruby:3.3.3

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      build-essential git libvips pkg-config nodejs npm cron && \
    npm install -g n && n lts && \
    npm install -g yarn && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir /app
WORKDIR /app

COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
COPY . /app

# entrypoint をLF化して実行権限を付与
COPY entrypoint.sh /usr/bin/entrypoint.sh
RUN sed -i 's/\r$//' /usr/bin/entrypoint.sh && chmod +x /usr/bin/entrypoint.sh

# bashで確実に実行
ENTRYPOINT ["bash", "/usr/bin/entrypoint.sh"]

EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]
