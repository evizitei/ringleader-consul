FROM ruby:2.2.3

RUN apt-get update && apt-get install -y wget bash unzip
RUN gem install diplomat -v=0.13.2

RUN mkdir /app
WORKDIR /app

#install docker-gen
RUN wget https://github.com/jwilder/docker-gen/releases/download/0.4.0/docker-gen-linux-amd64-0.4.0.tar.gz
RUN tar xvzf docker-gen-linux-amd64-0.4.0.tar.gz -C /usr/local/bin

# Install Consul
RUN curl -O -L -J https://dl.bintray.com/mitchellh/consul/0.5.2_linux_amd64.zip
RUN unzip -d /usr/local/bin/ 0.5.2_linux_amd64.zip


# Install Forego
RUN wget -P /usr/local/bin https://godist.herokuapp.com/projects/ddollar/forego/releases/current/linux-amd64/forego \
 && chmod u+x /usr/local/bin/forego

ADD . /app

ENV DOCKER_HOST unix:///var/run/docker.sock

CMD ["./startup"]
