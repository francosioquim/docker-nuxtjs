

#### Stage: Build Project
ARG VERSION=current

# Node alpine
FROM node:$VERSION-alpine as build
ARG PROJECT_ID
ARG USERNAME=${PROJECT_ID}
RUN echo ${PROJECT_ID}
RUN echo $USERNAME

# add git and open ssh
RUN echo @edge http://nl.alpinelinux.org/alpine/edge/main >> /etc/apk/repositories \
    && echo @edgecommunity http://nl.alpinelinux.org/alpine/edge/community >> /etc/apk/repositories \
    && apk update && apk add --upgrade apk-tools@edge && apk upgrade \
    && apk add --no-cache bash openssh gnupg \
    # installing build dependencies
    git python make g++ xz shadow \
    && apk add --no-cache --repository http://dl-3.alpinelinux.org/alpine/edge/testing vips-tools

# Add labels
# LABEL author="Franco Sioquim"

# Create user for our app
RUN useradd --user-group --create-home --shell /bin/false ${USERNAME}

# Set our home
ENV HOME=/home/${USERNAME}

# Switch to this user
USER ${USERNAME}

# Set the working directory to be
WORKDIR ${HOME}

USER root
RUN chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}
USER ${USERNAME}

## HAVE GLOBAL PACKAGE NOT STORED IN ROOT ACCESS LOCATION
RUN mkdir "${HOME}/.node"
# Tell npm where to store the globally installed packages
RUN echo 'prefix=~/.node' >> "${HOME}/.npmrc"
# Add the new bin and node_modules folders to your $PATH and $NODE_PATH variables
RUN echo 'PATH="$HOME/.node/bin:$PATH"' >> "${HOME}/.profile" \
    && echo 'NODE_PATH="$HOME/.node/lib/node_modules:$NODE_PATH"' >> "${HOME}/.profile" \
    && echo 'MANPATH="$HOME/.node/share/man:$MANPATH"' >> "${HOME}/.profile" \
    && source "${HOME}/.profile"


# Copy files
COPY package.json package.json
RUN yarn install
COPY . .

# set permissions
USER root
RUN chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}
USER ${USERNAME}

RUN yarn build


#### Stage: Copy Production files to Nginx
FROM nginx:alpine as production
ARG USERNAME=${PROJECT_ID}

VOLUME /var/cache/nginx

# Set our home
ENV HOME=/home/${USERNAME}

COPY --from=node /home/${USERNAME}/dist /usr/share/nginx/html
COPY .config/nginx.conf /etc/ningx/conf.d/default.conf

CMD ["nginx -g 'daemon off;'"]
