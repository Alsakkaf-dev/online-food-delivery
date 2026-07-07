# Multi-stage Dockerfile for the backend microservice
# Stage 1: build the Spring Boot jar with Maven
FROM maven:3.9.8-eclipse-temurin-21 AS build
WORKDIR /workspace

# Copy only the files needed for dependency resolution + source
COPY backend/pom.xml backend/mvnw backend/mvnw.cmd backend/.mvn ./backend/
COPY backend/src ./backend/src

# Ensure the Maven wrapper is executable and build the production jar
RUN chmod +x backend/mvnw \
    && cd backend \
    && ./mvnw -B package -DskipTests

# Stage 2: runtime image
FROM eclipse-temurin:21-jre-jammy
WORKDIR /app

# Copy the built Spring Boot jar from the build stage
COPY --from=build /workspace/backend/target/ofd-backend-0.0.1-SNAPSHOT.jar ./app.jar

EXPOSE 8080
ENV JAVA_OPTS=""
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar /app/app.jar"]
