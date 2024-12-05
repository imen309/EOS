FROM amazoncorretto:17-alpine-jdk

RUN apk update && \
    apk upgrade && \
    apk add --no-cache openssl

WORKDIR /app

ARG JAR_FILE=target/ecomm-order-1.0.jar
ADD ${JAR_FILE} .

ENTRYPOINT ["java","-jar","ecomm-order-1.0.jar"]
