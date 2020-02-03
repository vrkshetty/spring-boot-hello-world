FROM java:8
WORKDIR /
USER root
ADD app.jar /var/app.jar
EXPOSE 8080
ENTRYPOINT ["java","-Djava.security.egd=file:/dev/./urandom","-jar","/var/app.jar"]
