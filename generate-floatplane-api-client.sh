#!/bin/sh

openapi-generator generate \
 -i floatplane-openapi-specification-trimmed.json \
 -o FloatplaneAPIClient \
 -g swift5 \
 --library vapor \
 --global-property=apiDocs=false,modelDocs=false,apiTests=false,modelTests=false \
 --additional-properties=projectName=FloatplaneAPIClient
