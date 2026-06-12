# ── build stage ──────────────────────────────────────────────────────────────
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /workspace
# Cache dependencies separately from sources for fast rebuilds
COPY pom.xml .
RUN mvn -B -q dependency:go-offline
COPY src ./src
RUN mvn -B -q package -DskipTests

# ── runtime stage ─────────────────────────────────────────────────────────────
FROM eclipse-temurin:21-jre
LABEL org.opencontainers.image.title="Wakala Investment Account" \
      org.opencontainers.image.description="BIAN Service Domain: Wakala Investment Account (Fulfill)" \
      isb.business-area="Deposits and Investment Accounts" \
      isb.business-domain="Islamic Deposits"

RUN useradd --system --uid 10001 appuser
USER 10001
WORKDIR /app
COPY --from=build /workspace/target/isb-wakala-investment-account-*.jar app.jar

EXPOSE 8080
ENTRYPOINT ["java", "-XX:MaxRAMPercentage=75", "-jar", "/app/app.jar"]
