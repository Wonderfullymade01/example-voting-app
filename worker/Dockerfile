# because of dotnet, we always build on amd64, and target platforms in cli
# dotnet doesn't support QEMU for building or running.
# (errors common in arm/v7 32bit) https://github.com/dotnet/dotnet-docker/issues/1537
# hadolint ignore=DL3029
# to build for a different platform than your host, use --platform=<platform>
# for example: docker buildx build --platform "linux/arm64/v8" .

# build stage: compile the program with the full .NET 10 SDK (pinned version + digest)
FROM --platform=${BUILDPLATFORM} mcr.microsoft.com/dotnet/sdk:10.0.402@sha256:0d99ebf1ccad15037b5c98c9fe8979d6b8dbac23812feae2277a0b277b5c5ffa AS build
ARG TARGETPLATFORM
ARG TARGETARCH
ARG BUILDPLATFORM
RUN echo "I am running on $BUILDPLATFORM, building for $TARGETPLATFORM"

WORKDIR /source
COPY *.csproj .
RUN dotnet restore -a $TARGETARCH

COPY . .
RUN dotnet publish -c release -o /app -a $TARGETARCH --self-contained false --no-restore

# app image: only the small .NET 10 runtime (pinned version + digest), no compilers
FROM mcr.microsoft.com/dotnet/runtime:10.0.13@sha256:939555726cae4c916d212323ac3c0792996dcac2614f00e82cc40fcf059e1af3
WORKDIR /app

# Copy only the compiled program from the build stage
COPY --from=build /app .

# Switch to the built-in non-root "app" user (uid 1654) that ships with .NET 8+ images
USER $APP_UID

ENTRYPOINT ["dotnet", "Worker.dll"]
