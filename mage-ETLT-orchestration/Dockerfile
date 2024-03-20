FROM mageai/mageai:latest
ARG PIP=pip3

ARG PROJECT_NAME=github-trend
ARG MAGE_CODE_PATH=/home/src
ARG USER_CODE_PATH=${MAGE_CODE_PATH}/${PROJECT_NAME}

WORKDIR ${MAGE_CODE_PATH}
ENV USER_CODE_PATH=${USER_CODE_PATH}

COPY . .

RUN echo 'deb http://deb.debian.org/debian bullseye main' > /etc/apt/sources.list.d/bullseye.list && \
    apt-get update -y && \
    apt-get install -y openjdk-11-jdk && \
    rm /etc/apt/sources.list.d/bullseye.list

RUN ${PIP} install pyspark
RUN ${PIP} install -r ${USER_CODE_PATH}/requirements.txt

RUN python3 /app/install_other_dependencies.py --path ${USER_CODE_PATH}

ENV PYTHONPATH="${PYTHONPATH}:${USER_CODE_PATH}"

# # Add your custom entrypoint script
# RUN chmod +x /copying_credentials.sh

# # Set your custom entrypoint script
# ENTRYPOINT ["/copying_credentials.sh"]

CMD ["/bin/sh", "-c", "/app/run_app.sh"]
