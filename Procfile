consul: consul agent -server -client=0.0.0.0 -bootstrap-expect 1 -data-dir /tmp/consul
dockergen: docker-gen -interval 10 -watch -notify "ruby /tmp/ringleader.rb" ringleader.tmpl /tmp/ringleader.rb
