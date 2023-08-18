#!/bin/sh

mkdir -p FloatplaneAPIAsync/src
npx quicktype \
	--src async-schemas.json \
	--src-lang schema \
	--lang swift \
	--out FloatplaneAPIAsync/src/FloatplaneAPIAsyncModels.swift \
	--struct-or-class struct \
	--no-initializers \
	--coding-keys \
	--access-level public
