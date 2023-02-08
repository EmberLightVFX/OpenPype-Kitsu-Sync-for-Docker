# OpenPype Kitsu Sync for Docker
Run your OpenPype Kitsu Sync on your Docker server

For more information about the sync module, please visit OpenPypes webpage: [Kitsu Administration](https://openpype.io/docs/module_kitsu)

For more information about this dockerfile, please visit the [Github Page](https://github.com/EmberLightVFX/OpenPype-Kitsu-Sync-for-Docker)

## How to use this image
To run this image you will need to add a couple for environment variables:
```
docker run -d
-e OPENPYPE_VERSION=latest \
-e OPENPYPE_MONGO=mongodb://username:password@url.com \
-e KITSU_USERNAME=kitsu-user@url.com \
-e KITSU_PASSWORD=kitsu-passwrod \
--name openpype-kitsu-sync emberlightvfxopenpype-kitsu-sync:latest
```
Or for docker compose:
```
version: '3'
services:
  openpype-kitsu-sync:
    image: emberlightvfx/openpype-kitsu-sync:latest
    environment:
      - OPENPYPE_MONGO=mongodb://username:password@url.com
      - OPENPYPE_VERSION=latest
      - KITSU_USERNAME=kitsu-user@url.com
      - KITSU_PASSWORD=kitsu-passwrod
```

## Full Set up with docker-compose
One command install with docker-compose.
```
git clone https://github.com/EmberLightVFX/OpenPype-Kitsu-Sync-for-Docker.git
cd OpenPype-Kitsu-Sync-for-Docker
nano docker-compose.yaml
docker-compose up -d
```