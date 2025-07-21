# 3DCityDB PostGIS Dockerfile #################################################
#   Official website    https://www.3dcitydb.org
#   GitHub              https://github.com/3dcitydb
###############################################################################

# !! This file needs review and update !! (Karin) #############################



# Fetch & build stage #########################################################
# ARGS
ARG BASEIMAGE_TAG='...'
ARG BUILDER_IMAGE_TAG='...'

# Base image
FROM ...:${BUILDER_IMAGE_TAG} AS builder

# Copy source code
WORKDIR /build
COPY . /build

# Build
RUN chmod u+x ./gradlew && ./gradlew installDist

# Runtime stage ###############################################################
# Base image
FROM oracle/oracle:${BASEIMAGE_TAG} AS runtime

# Set 3DCityDB version
ARG CITYDB_VERSION
ENV CITYDB_VERSION=${CITYDB_VERSION}

# Copy SQL scripts
WORKDIR /3dcitydb
COPY --from=builder /build/build/install/3dcitydb/version.txt .
COPY --from=builder /build/build/install/3dcitydb/oracle/sql-scripts .
COPY --from=builder /build/build/install/3dcitydb/oracle/docker-scripts/3dcitydb-initdb.sh /docker-entrypoint-initdb.d/

# Make init script executable
RUN chmod +x /docker-entrypoint-initdb.d/3dcitydb-initdb.sh

# Set labels
LABEL maintainer=...
LABEL maintainer.email=...
LABEL maintainer.organization=...
LABEL source.repo=...
