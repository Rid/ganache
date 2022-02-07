# use full node to install dependencies
FROM node:14.17.4@sha256:cd98882c1093f758d09cf6821dc8f96b241073b38e8ed294ca1f9e484743858f AS builder

WORKDIR /app

COPY . .

# clean and install dependencies
RUN npm run clean
RUN npm ci --unsafe-perm

# import INFURA_KEY environment variable (build-arg)
ENV CREATE_BROKEN_BUILD "I WILL NOT PUBLISH THIS"

# build application
RUN npm run build

# prune development dependencies
RUN npx lerna exec --scope ganache -- npm prune --production

# we use node "slim" instead of "alpine" until we create a uwebsockets build for alpine.
FROM node:14.17.4-slim@sha256:766e2dcf4461582f7f750656807edbc28019753cecae92b1f2b25d13d3401ef3
ADD ./src/packages/ganache/entrypoint.sh /scripts/entrypoint.sh
RUN chmod +x /scripts/entrypoint.sh
RUN sed 's,LAST_UID=59999,LAST_UID=9999,' -i /etc/adduser.conf && \
    sed 's,LAST_GID=59999,LAST_GID=9999,' -i /etc/adduser.conf && \
    groupmod -g 9999 nogroup && \
    usermod -g 9999 nobody && \
    usermod -u 9999 nobody && \
    usermod -g 9999 sync && \
    usermod -g 9999 _apt

RUN apt update && \
    apt install -y --no-install-recommends \
    ca-certificates \
    curl \
    gnupg2 \
    software-properties-common \
    bash

WORKDIR /app

# copy from build image
COPY --from=builder /app/src/packages/ganache/node_modules node_modules
# TODO(perf): we don't need everything in here. Maybe either create a separate
# build for docker or cherry-pick the files we actually need.
COPY --from=builder /app/src/packages/ganache/dist/node dist/node

ENV DOCKER true
ENV NODE_ENV production

EXPOSE 8545

ENTRYPOINT [ "/scripts/entrypoint.sh" ]