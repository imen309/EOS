FROM amazoncorretto:17-alpine-jdk
WORKDIR /app
ARG JAR_FILE=target/ecomm-cart-1.0.jar
ADD ${JAR_FILE} .
RUN apk update && \
    apk add --no-cache \
    busybox \
    libssl3
ENTRYPOINT ["java","-jar","ecomm-cart-1.0.jar"]