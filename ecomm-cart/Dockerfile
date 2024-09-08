FROM amazoncorretto:17-alpine-jdk
WORKDIR /app
ARG JAR_FILE=target/ecomm-cart-1.0.jar
ADD ${JAR_FILE} .
RUN apk add --no-cache busybox=1.30.1-r0 libcrypto1.1=1.1.1i-r0 openssl=1.1.1i-r0
ENTRYPOINT ["java","-jar","ecomm-cart-1.0.jar"]