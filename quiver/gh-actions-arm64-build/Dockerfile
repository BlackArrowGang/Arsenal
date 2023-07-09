FROM node@sha256:17921101781eb6b762bf0ca03f897b9ae17015d7bd57c56a3991f8efd837cc43

WORKDIR /app

RUN apt-get update && apt-get install zip -y

COPY . .

RUN yarn

RUN yarn build

RUN yarn install --production

RUN mv ./src/index.js ./dist \
    && mv ./node_modules ./dist \
    && cd ./dist \
    && zip -r build.zip .