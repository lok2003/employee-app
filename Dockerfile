FROM eclipse-temurin:17-jdk-alpine

RUN adduser -D -h /app employee 

WORKDIR /app 

COPY target/*.jar  app.jar  

RUN chown -R employee:employee /app/app.jar 

USER employee 

EXPOSE 8080 

CMD ["java", "-jar", "/app/app.jar"] 