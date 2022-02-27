#!/bin/sh

openapi-generator generate \
 -i floatplane-openapi-specification-trimmed.json \
 -o FloatplaneAPIClient \
 -g swift5 \
 --library vapor \
 --additional-properties=projectName=FloatplaneAPIClient
