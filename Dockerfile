FROM --platform=linux/amd64 node:19 AS build

ENV NPM_CONFIG_PREFIX=/home/node/.npm-global

USER node
WORKDIR /home/node/app
COPY --chown=node:node /package.json /package-lock.json /home/node/app/
COPY --chown=node:node /src/ /home/node/app/src/
RUN npm ci --omit=dev 

FROM --platform=linux/amd64 node:19-alpine

ENV NPM_CONFIG_PREFIX=/home/node/.npm-global

USER node
WORKDIR /home/node/app
EXPOSE 4000

COPY --from=build --chown=node:node /home/node/app/src/  /home/node/app/src/
COPY --from=build --chown=node:node /home/node/app/package.json  /home/node/app/package.json /home/node/app/
RUN npm ci --omit=dev
ENV NODE_ENV=production

CMD ["node", "src/app.js"]