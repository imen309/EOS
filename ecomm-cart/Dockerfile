FROM amazoncorretto:17-alpine-jdk
WORKDIR /app
ARG JAR_FILE=target/ecomm-cart-1.0.jar
ADD ${JAR_FILE} .
RUN apt-get update && apt-get install -y \
    busybox \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*
ENTRYPOINT ["java","-jar","ecomm-cart-1.0.jar"]