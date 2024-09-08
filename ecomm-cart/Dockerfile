FROM amazoncorretto:17-alpine-jdk
WORKDIR /app
ARG JAR_FILE=target/ecomm-cart-1.0.jar
ADD ${JAR_FILE} .
RUN apk add busybox busybox-binsh libcrypto3 libssl13 ssl_client
ENTRYPOINT ["java","-jar","ecomm-cart-1.0.jar"]