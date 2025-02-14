
# Create a build argument
ARG BUILD_STAGE
ARG BUILD_STAGE=${BUILD_STAGE:-prod}

############# Build Stage: Dependencies ##################

# Start from a base image
FROM --platform=linux/amd64 ubuntu:focal as base

# Define a system argument
ARG DEBIAN_FRONTEND=noninteractive

# Install system libraries of general use
RUN apt-get update --allow-releaseinfo-change && apt-get install --no-install-recommends -y \
    build-essential \ 
    iptables \
    libdevmapper1.02.1 \
    python3.7\
    python3-pip \
    python3-setuptools \
    python3-dev \
    dpkg \
    sudo \
    wget \
    curl \
    dos2unix

############# Build Stage: Development ##################

# Build from the base image for dev
FROM base as dev

# Create working directory variable
ENV WORKDIR=/data

# Create a stage enviroment
ENV STAGE=dev

############# Build Stage: Production ##################

# Build from the base image for prod
FROM base as prod

# Create working directory variable
ENV WORKDIR=/data

# Create a stage enviroment
ENV STAGE=prod

# Copy all scripts to docker images
COPY . /spyne

############# Build Stage: Final ##################

# Build the final image 
FROM ${BUILD_STAGE} as final

# Set up volume directory in docker
VOLUME ${WORKDIR}

# Set up working directory in docker
WORKDIR ${WORKDIR}

# Allow permission to read and write files to current working directory
RUN chmod -R a+rwx ${WORKDIR}

############# Install java ##################

# Copy all files to docker images
COPY java /spyne/java

# Copy all files to docker images
COPY install_java.sh /spyne/install_java.sh

# Convert bash script from Windows style line endings to Unix-like control characters
RUN dos2unix /spyne/install_java.sh

# Allow permission to excute the bash script
RUN chmod a+x /spyne/install_java.sh

# Execute bash script to wget the file and tar the package
RUN bash /spyne/install_java.sh

############# Install bbtools ##################

# Copy all files to docker images
COPY bbtools /spyne/bbtools

# Copy all files to docker images
COPY install_bbtools.sh /spyne/install_bbtools.sh

# Convert bash script from Windows style line endings to Unix-like control characters
RUN dos2unix /spyne/install_bbtools.sh

# Allow permission to excute the bash script
RUN chmod a+x /spyne/install_bbtools.sh

# Execute bash script to wget the file and tar the package
RUN bash /spyne/install_bbtools.sh

############# Install Docker ##################

# Copy all files to docker images
COPY docker /spyne/docker

# Copy all files to docker images
COPY install_docker.sh /spyne/install_docker.sh

# Convert bash script from Windows style line endings to Unix-like control characters
RUN dos2unix /spyne/install_docker.sh

# Allow permission to excute the bash script
RUN chmod a+x /spyne/install_docker.sh

# Execute bash script to wget the file and tar the package
RUN bash /spyne/install_docker.sh

############# Install python packages ##################

# Copy all files to docker images
COPY requirements.txt /spyne/requirements.txt

# Install python requirements
RUN pip3 install --no-cache-dir -r /spyne/requirements.txt

############# Run spyne ##################

# Copy all files to docker images
COPY MIRA.sh /spyne/MIRA.sh

# Convert spyne from Windows style line endings to Unix-like control characters
RUN dos2unix /spyne/MIRA.sh

# Allow permission to excute the bash scripts
RUN chmod a+x /spyne/MIRA.sh

# Allow permission to read and write files to spyne directory
RUN chmod -R a+rwx /spyne

# Clean up
RUN apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# Export bash script to path
ENV PATH "$PATH:/spyne"
