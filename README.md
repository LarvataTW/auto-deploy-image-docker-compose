# auto-deploy-image-docker-compose
The GitLab Auto-Devops deploy stage image for deploy to non-k8s server with docker-compose.

## Prerequisites

- Docker 17.06.0+ (for supporting docker-compose 3.3 format)
- Install [Traefik](https://doc.traefik.io/traefik/user-guides/docker-compose/acme-http/)
- Create docker network `traefik-proxy`

## Install Traefik

The quick way, remember replace {YOUR_EMAIL} to yours:
```yml
version: "3.3"

services:

  traefik:
    image: "traefik:v2.4"
    container_name: "traefik"
    command:
      #- "--log.level=DEBUG"
      - "--api.insecure=true"
      - "--providers.docker=true"
      - "--providers.docker.exposedbydefault=false"
      - "--entrypoints.web.address=:80"
      - "--entrypoints.websecure.address=:443"
      - "--certificatesresolvers.myresolver.acme.httpchallenge=true"
      - "--certificatesresolvers.myresolver.acme.httpchallenge.entrypoint=web"
      #- "--certificatesresolvers.myresolver.acme.caserver=https://acme-staging-v02.api.letsencrypt.org/directory"
      - "--certificatesresolvers.myresolver.acme.email={YOUR_EMAIL}"
      - "--certificatesresolvers.myresolver.acme.storage=/letsencrypt/acme.json"
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - "./letsencrypt:/letsencrypt"
      - "/var/run/docker.sock:/var/run/docker.sock:ro"

networks:
  default:
    external:
      name: traefik-proxy
```

## Usage

Put below codes to your .gitlab-ci.yml and replace {YOUR_HOST_URL}.
```yml
include:
  - template: Auto-DevOps.gitlab-ci.yml

production:
  stage: production
  image: ghcr.io/larvatatw/auto-deploy-image-docker-compose:main
  variables:
    WORK_DIR: "/home/ubuntu/$CI_PROJECT_NAME/$CI_ENVIRONMENT_NAME"
  allow_failure: false
  script:
    - auto-deploy generate_docker_compose
    - auto-deploy prepare_ssh_enviroment
    - auto-deploy deploy
  rules:
    - if: '$STAGING_ENABLED'
      when: never
    - if: '$CANARY_ENABLED'
      when: never
    - if: '$INCREMENTAL_ROLLOUT_ENABLED'
      when: never
    - if: '$INCREMENTAL_ROLLOUT_MODE'
      when: never
    - if: '$CI_COMMIT_BRANCH == "master"'
      when: manual
  environment:
    name: production
    url: {YOUR_HOST_URL}
```
