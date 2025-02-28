ARG DATABASE_URL
ARG PORT
ARG JWT_KEY
ARG JWT_EXPIRES

# BUILD DEV
FROM node:latest AS development

RUN apt-get update && apt-get install -y "wait-for-it"

RUN yarn global add @nestjs/cli

WORKDIR /usr/src/app

RUN chown node:node .

USER node

COPY --chown=node:node package.json ./
COPY --chown=node:node yarn.lock ./

RUN yarn

COPY --chown=node:node . .

CMD [ "./run.sh" ]

# BUILD PROD
FROM node:16-alpine AS build

WORKDIR /usr/src/app

COPY --chown=node:node package.json ./
COPY --chown=node:node yarn.lock ./

COPY --chown=node:node --from=development /usr/src/app/node_modules ./node_modules

COPY --chown=node:node . .

ARG DATABASE_URL
ARG PORT
ARG JWT_KEY
ARG JWT_EXPIRES

RUN yarn build

ENV NODE_ENV production

RUN yarn && yarn cache clean

USER node

# PROD RUN
FROM node:16-alpine AS production

# Copy the bundled code from the build stage to the production image
COPY --chown=node:node --from=build /usr/src/app/node_modules ./node_modules
COPY --chown=node:node --from=build /usr/src/app/dist ./dist

# Start the server using the production build
CMD [ "node", "dist/src/main" ]
