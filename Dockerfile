# Utilise une image de base OpenJDK 17 officielle
FROM openjdk:17-jdk-slim

# Définir le répertoire de travail dans le conteneur
WORKDIR /app

# Copier le fichier JAR de l'application dans le conteneur
COPY ./target/*.jar app.jar

# Exposer le port sur lequel l'application fonctionne (par exemple, 8080)
EXPOSE 8080

# Démarrer l'application
CMD ["java", "-jar", "app.jar"]
