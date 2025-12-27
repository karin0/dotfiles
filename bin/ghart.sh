#!/bin/bash
set -e

usage() {
  echo "Usage: $0 [-o out] [-g grep] [-b branch] <repo-name>" >&2
  exit 1
}

token="$GHART_TOKEN"
if [ -z "$token" ]; then
  echo "GHART_TOKEN unset" >&2
  exit 1
fi

OPTIND=1
while [ $OPTIND -le "$#" ]; do
  if getopts o:g:b: opt; then
    case $opt in
      o) out=$OPTARG ;;
      g) grep=$OPTARG ;;
      b) branch=$OPTARG ;;
      *) usage
    esac
  else
    [ -v repo ] && usage
    repo="${!OPTIND}"
    ((OPTIND++))
  fi
done

[ -v repo ] || usage

if [ -n "$grep" ]; then
  filt="| map(select(.name | contains(\"$grep\")))"
fi
if [ -n "$branch" ]; then
  filt+=" | map(select(.workflow_run.head_branch == \"$branch\"))"
fi

auth="Authorization: Bearer $token"
o=$(curl \
  -H "Accept: application/vnd.github+json" \
  -H "$auth" \
  https://api.github.com/repos/"$repo"/actions/artifacts)

echo "$o"
o=$(echo "$o" | jq -r ".artifacts $filt [0]")
echo "$o"
if [ "$o" = null ]; then
  echo "No artifacts found" >&2
  exit 1
fi
echo "$o" | jq >&2
name="$(echo "$o" | jq -r .name)"
url="$(echo "$o" | jq -r .archive_download_url)"

if [ -z "$out" ]; then
  out="$name"
  if [ -e "$out" ]; then
    i=1
    while [ -e "$out.$i" ]; do
      ((i++))
    done
  fi
  echo "$out"
elif [ "$out" = - ]; then
  out=/dev/stdout
fi

curl -L -H "$auth" "$url" | zcat > "$out"
