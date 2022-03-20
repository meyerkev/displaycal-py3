FROM python:3.9.7
WORKDIR /opt/displaycal
RUN apt-get update && apt-get upgrade -y

COPY packages.list packages.list
RUN apt-get install -y $(grep -o ^[^#][[:alnum:]-]*.* "packages.list" | grep -v libreadline-gplv2-dev)
RUN apt-get install -y apt-file && apt-file update
COPY . .
RUN pip install --upgrade wheel pip && make requirements && make build && make install

CMD ["scripts/displaycal"]
