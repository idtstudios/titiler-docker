FROM python:3.9

LABEL maintainer="Sebastian Ramirez <tiangolo@gmail.com>"

COPY requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt

COPY ./start.sh /start.sh
RUN chmod +x /start.sh

COPY ./gunicorn_conf.py /gunicorn_conf.py

COPY ./start-reload.sh /start-reload.sh
RUN chmod +x /start-reload.sh

COPY ./app /app
WORKDIR /app/

ENV PYTHONPATH=/app

EXPOSE 80

# Run the start script, it will check for an /app/prestart.sh script (e.g. for migrations)
# And then will start Gunicorn with Uvicorn
CMD ["/start.sh"]

# Ensure root certificates are always updated at evey container build
# and curl is using the latest version of them
RUN mkdir /usr/local/share/ca-certificates/cacert.org
RUN cd /usr/local/share/ca-certificates/cacert.org && curl -k -O https://www.cacert.org/certs/root.crt
RUN cd /usr/local/share/ca-certificates/cacert.org && curl -k -O https://www.cacert.org/certs/class3.crt
RUN update-ca-certificates
ENV CURL_CA_BUNDLE /etc/ssl/certs/ca-certificates.crt

COPY src/titiler/ /tmp/titiler/
RUN pip install /tmp/titiler/core /tmp/titiler/mosaic /tmp/titiler/application --no-cache-dir --upgrade
RUN rm -rf /tmp/titiler

ENV MODULE_NAME titiler.application.main
ENV VARIABLE_NAME app
