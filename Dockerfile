FROM node:22-bookworm-slim AS builder

ENV YARN_NETWORK_TIMEOUT=600000

RUN apt-get update && \
    apt-get install -y --no-install-recommends python3 python3-pip python3-venv g++ build-essential

WORKDIR /app

COPY package.json yarn.lock ./
COPY packages/backend/package.json packages/backend/
COPY packages/app/package.json packages/app/

RUN --mount=type=cache,target=/root/.cache/yarn,sharing=locked \
    yarn install --ignore-engines --network-timeout 300000

COPY . .

RUN yarn build:backend

FROM node:22-bookworm-slim

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && \
    apt-get install -y --no-install-recommends python3 python3-pip python3-venv g++ build-essential && \
    yarn config set python /usr/bin/python3

ENV VIRTUAL_ENV=/opt/venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"
RUN pip3 install mkdocs-techdocs-core

USER node

WORKDIR /app

ENV NODE_ENV production

COPY --from=builder --chown=node:node /app/packages/backend/dist/skeleton.tar.gz /app/yarn.lock /app/package.json ./
RUN tar xzf skeleton.tar.gz && rm skeleton.tar.gz

RUN --mount=type=cache,target=/home/node/.cache/yarn,sharing=locked,uid=1000,gid=1000 \
    yarn install --ignore-engines --production --network-timeout 300000

COPY --from=builder --chown=node:node /app/packages/backend/dist/bundle.tar.gz ./
RUN tar xzf bundle.tar.gz && rm bundle.tar.gz

COPY --chown=node:node app-config*.yaml ./
COPY --chown=node:node ./catalog/entities ./entities

CMD ["node", "packages/backend", "--config", "app-config.yaml", "--config", "app-config.production.yaml"]
