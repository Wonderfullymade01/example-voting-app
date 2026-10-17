# Pinned Node 22 (LTS) slim image: exact version + digest so every build is identical
FROM node:22.23.3-slim@sha256:c3de60bf2f9dd0ac6370e6117950ff62d6e339527e7472301c9c78a017978392

# add curl for healthcheck, tini for signals; upgrade installs Debian security fixes
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends curl tini && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /usr/local/app

# have nodemon available for local dev use (file watching), pinned
RUN npm install -g nodemon@3.1.14

COPY package*.json ./

# Install exact dependency versions from package-lock.json, then move them out of the app folder
RUN npm ci && \
 npm cache clean --force && \
 mv /usr/local/app/node_modules /node_modules

 # npm/npx/corepack are only needed at build time; remove them (and their bundled libraries) from the image
RUN rm -rf /usr/local/lib/node_modules/npm /usr/local/lib/node_modules/corepack \
    /usr/local/bin/npm /usr/local/bin/npx /usr/local/bin/corepack

# Copy our code and make the built-in non-root "node" user the owner (instead of root)
COPY --chown=node:node . .

# Listen on 8080 (non-root users can't use ports below 1024, like 80)
ENV PORT=8080
EXPOSE 8080

# Switch to the non-root "node" user that ships with the official image
USER node

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["node", "server.js"]
