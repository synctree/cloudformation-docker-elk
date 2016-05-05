FROM kibana:4.5

RUN apt-get update
RUN kibana plugin --install elastic/sense

ENV ELASTICSEARCH_ENDPOINT http://elasticsearch:9200

ENTRYPOINT ["/bin/bash", "-c", "kibana --elasticsearch $ELASTICSEARCH_ENDPOINT"]
