#!/bin/bash

export AUTH_TOKEN=$(./scripts/bin/get_token.sh)
export REPORT_TITLE="report_$(date +%s)"

# 1. Update all add-ons
# 2. Install alpha and beta rules, make sure that GraalJS is available
# 3. Execute test plan (YAML)
docker run --rm -e "AUTH_TOKEN=$AUTH_TOKEN" -e "REPORT_TITLE=$REPORT_TITLE" -v "$(pwd):/zap/wrk/" zaproxy/zap-stable \
    bash -c "\
    zap.sh -cmd -addonupdate; \
    zap.sh -cmd -addoninstall communityScripts \
    -addoninstall pscanrulesAlpha \
    -addoninstall pscanrulesBeta \
    -addoninstall graaljs \
    -autorun /zap/wrk/zap.yaml"