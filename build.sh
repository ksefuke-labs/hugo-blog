#!/usr/bin/env bash
main() {
 HUGO_VERSION=0.154.5

 export TZ=Europe/London

 # Install Hugo
 echo "Installing Hugo v${HUGO_VERSION}...."
 curl -LJO https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_linux-amd64.tar.gz
 tar -xf "hugo_extended_${HUGO_VERSION}_linux-amd64.tar.gz"
 cp hugo /opt/buildhome
 rm hugo_extended_${HUGO_VERSION}_linux-amd64.tar.gz

 # Verify Installed versions
 echo "Verifying installations"
 echo Go: "$(go version)"
 echo Hugo: "$(hugo version)"
 echo Node.js: "$(node --version)"

 # Clone themes Repo
 echo "Clone Blowfish"
 git submodule update --init --recursive
 git config core.quotepath false

 # Building the website
 echo "Building the site"
 hugo --gc --minify

}

set -euo pipefail
main "$@"