# git cloner

> This script clone a specific folder from git repository.

## Environment Variables

This script requires the following environment variables:

 - AZ_TOKEN: Azure DevOps PAT
 - REPOSITORY_URL: git repository URL (https protocol)
 - REPOSITORY_BRANCH_NAME: branch to checkout
 - REPOSITORY_TEST_FOLDER: target folder
 - REQUIRED_FILE_PATTERN: regex pattern to check if required files exist in target folder
 - OUTPUT_FOLDER: output folder to copy required files

---

## Setup

Create the `.env` file with the corresponding key/value pair of environment variables.

Example:

```
AZ_TOKEN=46eyj9v4w1bvv85739q5e71f4i60m1hlv5gjsoqbj3u0ne27vhiy
REPOSITORY_URL=https://dev.azure.com/icazacarlos/webapp/_git/git-cloner
REPOSITORY_BRANCH_NAME=master
REPOSITORY_TEST_FOLDER=tests
REQUIRED_FILE_PATTERN=Kafka-Test*.json
OUTPUT_FOLDER=/app/tests/
```

## Execute

Run the script

```
./script.sh
```

---

## Docker

### Build the image

```
docker build --no-cache -t local/git-cloner:1.0 .
```

### Run the container

```
docker run --rm \
  -e AZ_TOKEN="iwz5me76imqjrbqd5mru7wrqt3kpmmexdra24ahoogtf4bra4vwq" \
  -e REPOSITORY_BRANCH_NAME="feature/brahian" \
  -e REPOSITORY_TEST_FOLDER=tests \
  -e REPOSITORY_URL="https://dev.azure.com/bhdleon/BHDL-Prueba-Concepto/_git/system_poc_event_hub_example"
  -e REQUIRED_FILE_PATTERN="Kafka-Test*.json" \
  -e OUTPUT_FOLDER="/app/tests/" \
  local/git-cloner:1.0
```

### Use Docker Compose

Always build the image before run
```
docker compose up --build
```

Run with previously built image or build the image if it doesn't exist
```
docker compose up
```

### Extra Setup

Run security checks over Docker image

 - Docker Scout

```
docker scout cves local/git-cloner:1.0
```

 - Trivy

```
trivy image local/git-cloner:1.0
```
