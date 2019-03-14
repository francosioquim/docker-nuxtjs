# docker-nuxtjs

> Dockerised NuxtJS App

## Preconfigured Options
- Express
- Vuetify
- Jest
- Universal mode
- Axios
- EsLint
- Prettier

## Usage

``` bash
# install dependencies
$ yarn install

# serve with hot reload at localhost:3000
$ yarn dev

# build for production and launch server
$ yarn build

```

## Docker

```bash
# replace `docker-nuxtjs` to your preferred project name
$ docker build -t docker-nuxtjs --no-cache -f dockerfile . --build-arg PROJECT_ID=docker-nuxtjs

$ docker run -p 80:80 docker-nuxtjs
```

For detailed explanation on how things work, checkout [Nuxt.js docs](https://nuxtjs.org).
