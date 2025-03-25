FROM python:3.11

# Install Azure CLI
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

ENV PORT=8080
EXPOSE 8080

COPY ./docker-entry.sh /
RUN chmod +x /docker-entry.sh

WORKDIR /usr/src/app
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY ./*.py .

ENTRYPOINT ["/docker-entry.sh"]
