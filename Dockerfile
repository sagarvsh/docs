FROM python:3.8.1-alpine3.11

# Build-time flags
ARG WITH_PLUGINS=true

# Set build directory
WORKDIR /tmp

# Copy files necessary for build
COPY material material
COPY MANIFEST.in MANIFEST.in
COPY package.json package.json
COPY README.md README.md
COPY requirements.txt requirements.txt
COPY setup.py setup.py

# Perform build and cleanup artifacts
RUN \
  apk add --no-cache \
    git \
    git-fast-import \
    openssh \
  && apk add --no-cache --virtual .build gcc musl-dev \
  && pip install --no-cache-dir . \
  && \
    if [ "${WITH_PLUGINS}" = "true" ]; then \
      pip install --no-cache-dir \
        'mkdocs-minify-plugin>=0.3' \
        'mkdocs-redirects>=1.0'; \
    fi \
  && apk del .build gcc musl-dev \
  && rm -rf /usr/local/lib/python3.8/site-packages/mkdocs/themes/*/* \
  && rm -rf /tmp/*

# Set working directory
WORKDIR /docs

# Expose MkDocs development server port
EXPOSE 8000

# Start development server by default
ENTRYPOINT ["mkdocs"]
CMD ["serve", "--dev-addr=0.0.0.0:8000"]
