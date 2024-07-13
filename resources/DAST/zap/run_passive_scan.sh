#!/bin/bash

export REPORT_TITLE="report_$(date +%s)"

# 1. Update all add-ons
# 2. Install alpha and beta rules
# 3. Execute test plan passive_scan.yaml
docker run --rm -e "REPORT_TITLE=$REPORT_TITLE" -v "$(pwd):/zap/wrk/" zaproxy/zap-stable \
    bash -c "\
    zap.sh -cmd -addonupdate; \
    zap.sh -cmd -addoninstall communityScripts \
    -addoninstall pscanrulesAlpha \
    -addoninstall pscanrulesBeta \
    -autorun /zap/wrk/passive_scan.yaml"