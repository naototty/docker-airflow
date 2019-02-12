# VERSION 1.10.2a
# AUTHOR: Matthieu "Puckel_" Roisil
# MAINTAINER: Naoto "naototty" Gohko
# DESCRIPTION: Basic Airflow container
# BUILD: docker build --rm -t naototty/docker-airflow .
# SOURCE: https://github.com/naototty/docker-airflow

FROM naototty/alpine-v39-pip3
LABEL maintainer="naototty"

# Never prompts the user for choices on installation/configuration of packages
ENV TERM linux

# Airflow env
ARG AIRFLOW_VERSION=1.10.2
ARG AIRFLOW_HOME=/usr/local/airflow
ENV AIRFLOW_USER=airflow
ENV AIRFLOW_DB_USER=airflow

ARG AIRFLOW_DEPS=""
ARG PYTHON_DEPS=""
ENV AIRFLOW_GPL_UNIDECODE yes

# Define en_US.
ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV LC_CTYPE en_US.UTF-8
ENV LC_MESSAGES en_US.UTF-8

## RUN useradd -ms /bin/bash -d ${AIRFLOW_HOME} -G sudo ${AIRFLOW_USER} && \
RUN useradd -ms /bin/bash -d ${AIRFLOW_HOME} ${AIRFLOW_USER}
ADD etc-apk-repositories /etc/apk/repositories

# add to application
WORKDIR ${AIRFLOW_HOME}

COPY requirements.txt ${AIRFLOW_HOME}
RUN apk update && \
    apk add -u py3-lxml py-numpy@community py-numpy-f2py@community py-numpy-dev@community py-numpy-doc@community py3-numpy@community py3-numpy-f2py@community && \
    rm -rf /var/lib/apt/lists/*
## RUN pip3 install -r requirements.txt && \
RUN pip3 install pytz && \
        pip3 install pyOpenSSL && \
        pip3 install ndg-httpsclient && \
        pip3 install pyasn1 && \
        pip3 install 'redis>=2.10.5,<3' && \
    pip3 install apache-airflow[crypto,celery,postgres,password,slack,s3,ssh${AIRFLOW_DEPS:+,}${AIRFLOW_DEPS}]==${AIRFLOW_VERSION}
##    pip3 install apache-airflow[crypto,celery,postgres,s3,ssh${AIRFLOW_DEPS:+,}${AIRFLOW_DEPS}]==${AIRFLOW_VERSION} \
ADD ./airflow ${AIRFLOW_HOME}

##         && pip3 install pytz \
##         && pip3 install pyOpenSSL \
##         && pip3 install ndg-httpsclient \
##         && pip3 install pyasn1 \
##         && pip3 install numpy \
##         && pip3 install apache-airflow[crypto,celery,postgres,s3,ssh${AIRFLOW_DEPS:+,}${AIRFLOW_DEPS}]==${AIRFLOW_VERSION} \
##         && pip3 install 'redis>=2.10.5,<3' \
##         && if [ -n "${PYTHON_DEPS}" ]; then pip install ${PYTHON_DEPS}; fi \
##      && rm -rf \
##          /tmp/* \
##          /var/tmp/* \
##          /usr/share/man \
##          /usr/share/doc \
##          /usr/share/doc-base
 
COPY script/entrypoint.sh /entrypoint.sh
COPY config/airflow.cfg ${AIRFLOW_HOME}/airflow.cfg
RUN chown -R ${AIRFLOW_USER}.${AIRFLOW_USER} ${AIRFLOW_HOME}


EXPOSE 8080 5555 8793

USER airflow
WORKDIR ${AIRFLOW_HOME}
ENTRYPOINT ["/entrypoint.sh"]
CMD ["webserver"] # set default arg for entrypoint
