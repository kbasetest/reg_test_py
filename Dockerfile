FROM python:3.12-trixie
LABEL maintainer="KBase Developer"
# -----------------------------------------
# Set up SDK requirements

# In this section, we install code required for the SDK to run.

# Don't spam the KBase Catalog logs
ENV PIP_PROGRESS_BAR=off

# Install general binaries
RUN apt update && apt install -y wget

# Install the SDK binary. This is required for spec compilation and catalog registration.
ENV SDK_VER=0.1.0-alpha2
ENV SDK_SHA=a80d761fc5b27f043b5eb584f4e28c1d15bf920bdb257fc61a0b64fe97b0c87a
RUN mkdir -p /sdk/bin \
    && wget -O /sdk/bin/kb-sdk https://github.com/kbase/kb_sdk_plus/releases/download/$SDK_VER/kb-sdk-linux-x64 \
    && echo "$SDK_SHA /sdk/bin/kb-sdk" | sha256sum --check \
    && chmod a+x /sdk/bin/kb-sdk
ENV PATH=/sdk/bin:$PATH

# Install python libraries required by the SDK code.
# You may wish to use a dependency manager like pipenv or uv to install
# these as well as your own dependencies.
# Note uwsgi can be removed if this module is not a dynamic service, which is usually the case
RUN pip install \
    requests==2.32.5 \
    jsonrpcbase==0.2.0 \
    jinja2==3.1.6 \
    uwsgi==2.0.30 \
    pytest==8.4.2 \
    pytest-cov==6.2.1

# -----------------------------------------
# In this section, you can install any system dependencies required
# to run your App.  For instance, you could place an apt-get update or
# install line here, a git checkout to download code, or run any other
# installation scripts.

# RUN apt-get update


# -----------------------------------------

COPY ./ /kb/module
RUN mkdir -p /kb/module/work
RUN chmod -R a+rw /kb/module

WORKDIR /kb/module

RUN make all

ENTRYPOINT [ "./scripts/entrypoint.sh" ]

CMD [ ]
