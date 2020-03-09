FROM ubuntu:18.04 as target

ENV LANG C.UTF-8

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y \
  ca-certificates \
  libgmp-dev \
  netbase

FROM haskell:8.8 as build

WORKDIR /tmp

COPY stack.yaml .
COPY stack.yaml.lock .
COPY .docker/fake-package.yaml package.yaml
RUN stack setup
RUN cabal update
RUN rm package.yaml

COPY arrow.cabal .
RUN stack build --only-dependencies -j4

WORKDIR /app

# Build the actual project
COPY . .
RUN stack install --local-bin-path /app/bin

FROM target

WORKDIR /app

COPY --from=build /app/bin/arrow /app/arrow
ENTRYPOINT ["/app/arrow"]
