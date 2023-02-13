FROM node:19 AS build

USER node
WORKDIR /home/node/app
COPY --chown=node:node /package.json /package-lock.json /home/node/app/
COPY --chown=node:node /src/ /home/node/app/src/
RUN npm install

FROM node:19-alpine

USER node
WORKDIR /home/node/app
EXPOSE 4000

COPY --from=build --chown=node:node /home/node/app/src/  /home/node/app/src/
COPY --from=build --chown=node:node /home/node/app/package.json  /home/node/app/package.json /home/node/app/
RUN npm install --omit=dev
ENV NODE_ENV=production

CMD ["node", "src/app.js"]