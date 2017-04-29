FROM node:6.9.1

RUN printenv
RUN npm config set registry http://registry.npmjs.org/
RUN npm install -g node-gyp
#RUN npm install -g grunt-cli

WORKDIR /app
ADD package.json /app/
RUN npm install
ADD . /app

EXPOSE 3000
CMD npm start
