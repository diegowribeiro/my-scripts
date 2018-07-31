#!/bin/bash

## Variaveis de configuração
name='jenkins_slave'
ip=$(docker inspect --format '{{.NetworkSettings.IPAddress}}' jenkins_lab)
echo $ip | grep 172 || exit 1
url="http://$ip:8080/computer/Dockerhost-LAB/slave-agent.jnlp"
secret='b210f89fe25a3ebe93096be982071ecae7f0829f516830e59f6873250251f990'


## Inicia o slave
function start() {
  java -jar slave.jar \
    -jnlpUrl $url \
    -secret $secret &
  echo $! >${name}.pid
  disown
}


## Para e remove o container, mantendo os arquivos persistidos
function stop() {
  kill -9 $(cat ${name}.pid) || true
}


## Reinicia o container
function restart() {
  stop
  start
}


## Mostra se o container esta rodando
function status() {
  ps -ef | grep -v grep | grep slave.jar 
}


## Mostra como usar o script
function ajuda() {
cat <<-EOF
    O script $0 controla a execução do $name
    Uso:
    $0 <start|stop|restart>
EOF
}


## Verifica o parametro inicial passado para o script
case $1 in
  start) start;;
  stop) stop;;
  restart) restart;;
  status) status;;
  *) ajuda;;
esac
