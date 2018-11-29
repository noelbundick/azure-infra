#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

RG=''
LOCATION=''
UPN=''

show_usage() {
  echo "Usage: deploy.sh --resource-group <rg> --location <location> --user-principal-name <upn>"
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
      -u|--user-principal-name)
        UPN=$2
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
  if [[ -z $RG || -z $LOCATION || -z $UPN || -z $BASENAME ]]; then
    show_usage
    exit 1
  fi
}

deploy() {
  # convert UPN to objectId
  USER_OID=$(az ad user show --upn-or-object-id $UPN --query objectId -o tsv)

  az group create -n $RG -l $LOCATION
  az group deployment create -g $RG --template-file ./azuredeploy.json --parameters baseName=$BASENAME userObjectId=$USER_OID
}

parse_arguments "$@"
validate_arguments

set -x
deploy