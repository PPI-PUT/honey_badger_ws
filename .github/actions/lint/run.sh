#!/bin/bash
set -e

./.github/scripts/setup.sh
ament_${LINTER} src/
