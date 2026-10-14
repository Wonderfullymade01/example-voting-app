# base defines a base stage that uses the official python runtime base image
FROM python:3.11.17-slim@sha256:e88e9763f943ec1834f992a4b51e0f24500486803e8bc534e5767af9ea65f6ce AS base

# Add curl for healthcheck
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl && \
    rm -rf /var/lib/apt/lists/*

# Set the application directory
WORKDIR /usr/local/app

# Install our requirements.txt
COPY requirements.txt ./requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Create a non-root user (uid 10001) to run the app
RUN useradd --create-home --uid 10001 appuser

# dev defines a stage for development, where it'll watch for filesystem changes
FROM base AS dev
RUN pip install watchdog

# Switch to the non-root user after installing packages (installing packages needs root)
USER appuser
ENV FLASK_ENV=development
CMD ["python", "app.py"]

# final defines the stage that will bundle the application for production
FROM base AS final

# Copy our code into the working directory and make appuser the owner (instead of root)
COPY --chown=appuser:appuser . .

# Switch to the non-root user so the app doesn't run with admin rights
USER appuser

# Make port 8080 available (non-root users can't use ports below 1024, like 80)
EXPOSE 8080

# Start the app with gunicorn on port 8080; send logs to the console so docker logs shows them
CMD ["gunicorn", "app:app", "-b", "0.0.0.0:8080", "--log-file", "-", "--access-logfile", "-", "--workers", "4", "--keep-alive", "0"]
