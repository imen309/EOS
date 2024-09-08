FROM amazoncorretto:21-alpine3.17-jdk
WORKDIR /app
ARG JAR_FILE=target/ecomm-cart-1.0.jar
ADD ${JAR_FILE} .
RUN apk add --no-cache busybox busybox-binsh libcrypto3 openssl
ENTRYPOINT ["java","-jar","ecomm-cart-1.0.jar"]