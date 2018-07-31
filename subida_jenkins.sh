#!/bin/bash

## Variaveis de configuração
name='jenkins'
imagem='jenkins:latest'
porta1='80:8080'
porta2='50000:50000'
diretorio1='/home/devops/Star/Automatizacao/Jenkins/Master/Storage:/var/jenkins_home'
regiao='-Duser.timezone=America/Sao_Paulo'
fixsec='-Dhudson.model.ParametersAction.keepUndefinedParameters=true'
cmdbash='echo "yes" | keytool -import -alias ldap -keystore "$JAVA_HOME"/jre/lib/security/cacerts -file /var/jenkins_home/ssl/CertificadoRootSelfSignedPRODUCAO.der -storepass changeit'
fixgit='cat /etc/ssl/certs/ca-certificates.crt /var/jenkins_home/ssl/git_ssl.crt > /etc/ssl/certs/ca-certificates.crt'

## Inicia o container
function start() {
  docker run -d \
    --restart always \
    --name $name \
    -p $porta1 -p $porta2 \
    -v $diretorio1 \
    -e "JAVA_OPTS=$regiao $fixsec" \
    $imagem
  
  echo -e "[Docker] Created jenkins container ..."

  docker exec -ti -u root $name bash -c "$cmdbash;$fixgit" &> /dev/null

  echo -e "[Docker] LDAP and GIT SSL imported ..."

  docker restart $name &> /dev/null

  echo -e "[Docker] Restarting container to apply changes ...\n[Docker] Jenkins up"
}


## Para e remove o container, mantendo os arquivos persistidos
function stop() {
  docker rm -f $name || true
}


## Reinicia o container
function restart() {
  stop
  start
}


## Mostra se o container esta rodando
function status() {
  docker ps -a | grep $name | tr '\t' ' ' | tr -s ' '
}


## Mostra como usar o script
function ajuda() {
cat <<-EOF
    O script $0 controla a execução do container $name
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