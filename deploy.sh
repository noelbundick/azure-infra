#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

RG=''
LOCATION=''
USER_OID=''

show_usage() {
  echo "Usage: deploy.sh --resource-group <rg> --location <location> --user-object-id <objectId>"
}

parse_arguments() {
  PARAMS=""
  while (( $# )); do
    case "$1" in
      -h|--help)
        show_usage
        exit 0
        ;;
      -g|--resource-group)
        RG=$2
        shift 2
        ;;
      -l|--location)
        LOCATION=$2
        shift 2
        ;;
      -u|--user-object-id)
        USER_OID=$2
        shift 2
        ;;
      -n|--baseName)
        BASENAME=$2
        shift 2
        ;;
      --)
        shift
        break
        ;;
      -*|--*)
        echo "Unsupported flag $1" >&2
        exit 1
        ;;
      *)
        PARAMS="$PARAMS $1"
        shift
        ;;
    esac
  done
}

validate_arguments() {
  if [[ -z $RG || -z $LOCATION || -z $USER_OID || -z $BASENAME ]]; then
    show_usage
    exit 1
  fi
}

deploy() {
  az group create -n $RG -l $LOCATION
  az group deployment create -g $RG --template-file ./azuredeploy.json --parameters baseName=$BASENAME userObjectId=$USER_OID
}

parse_arguments "$@"
validate_arguments

set -x
deploy