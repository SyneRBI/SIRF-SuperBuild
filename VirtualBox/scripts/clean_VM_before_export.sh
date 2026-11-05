#! /bin/bash
# Wrapper for clean_before_VM_export.sh
location=`dirname "$0"`
exec "$location/clean_before_VM_export.sh" "$@"
