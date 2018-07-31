#!/bin/bash
sonar_name="sonarqube"
sonar_imagem="sonarqube"
sonar_porta1="9000:9000"
sonar_porta2="9002:9002"
sonar_username="SONARQUBE_JDBC_USERNAME=sonar"
sonar_passwd="SONARQUBE_JDBC_PASSWORD=sonar"
sonar_url="SONARQUBE_JDBC_URL=jdbc:postgresql://postgres:5432/sonar"
sonar_volume1="/var/lib/docker/jenkins/sonar-data:/opt/sonarqube/data"
sonar_volume2="/var/lib/docker/jenkins/sonar-extensions:/opt/sonarqube/extensions"
postgres_imagem="postgres"
postgres_name="postgres"
postgres_porta="5432"
postgres_db="POSTGRES_DB=sonar"
postgres_user="POSTGRES_USER=sonar"
postgres_passwd="POSTGRES_PASSWORD=sonar"
postgres_volume="/var/lib/docker/jenkins/sonar-database:/var/lib/postgresql/data"

function start_stack_sonar() {
        echo "Iniciando o postgres..."
        docker run -d --restart always --expose=$postgres_porta -v $postgres_volume --name $postgres_name -e $postgres_db -e $postgres_user -e $postgres_passwd $postgres_imagem

        echo "Iniciando o sonar..."
        docker run -d --restart always -p $sonar_porta1 -p $sonar_porta2 --name $sonar_name  --link $postgres_name -v $sonar_volume1 -v $sonar_volume2 -e $sonar_username -e $sonar_passwd -e $sonar_url $sonar_imagem
}

function stop_stack_sonar() {
        echo "Removendo o container hub selenium"
        docker ps | grep sonar | awk '{print $1}' | xargs docker rm -f
        docker ps | grep postgres | awk '{print $1}' | xargs docker rm -f
}

function status_stack_sonar() {
        docker ps | grep sonar
        docker ps | grep postgres
}

function ajuda() {
cat <<-EOF
    O script $0 controla a execução do container $name
    Uso:
    $0 <start|stop|status>
EOF
}

case $1 in
        start) start_stack_sonar;;
        stop) stop_stack_sonar;;
        status) status_stack_sonar;;
        *) ajuda;;
esac