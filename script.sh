#!/bin/bash

# -------------------------------------------------------- 
# This script clone a specific folder from git repository
# --------------------------------------------------------

source config/colors.sh

# Required Environment Variable
#  - AZ_TOKEN
#  - REPOSITORY_URL
#  - REPOSITORY_BRANCH_NAME
#  - REPOSITORY_TEST_FOLDER
#  - REQUIRED_FILE_PATTERN
#  - OUTPUT_FOLDER

trap cleanup ERR EXIT

function cleanup () {
  echo "Cleanup Done!"
  rm -rf ${TMP_DIR}
}

LOCAL_ENVIRONMENT_FILENAME=.env
if [ -s "${LOCAL_ENVIRONMENT_FILENAME}" ]; then
  set -o allexport
  source .env
  set +o allexport
fi

TMP_DIR=$(mktemp --directory -t git-fetch-XXXXXXX)
TMP_EXTRAHEADER_FILE=$(mktemp -p ${TMP_DIR} git-header-XXXXXXX)
B64_PAT=$(printf "%s""pat:${AZ_TOKEN}" | base64)
echo "GIT_HTTP_EXTRAHEADER='Authorization: Basic ${B64_PAT}'" > $TMP_EXTRAHEADER_FILE

set -o allexport
source $TMP_EXTRAHEADER_FILE
set +o allexport

echo "----------------------------------------"
echo " Git Cloner"
echo "  Repository URL: ${REPOSITORY_URL}"
echo "  Branch: ${REPOSITORY_BRANCH_NAME}"
echo "----------------------------------------"

ERROR_FILE=${PWD}/error.log
touch ${ERROR_FILE}
mkdir -p ${OUTPUT_FOLDER}
cd ${TMP_DIR}

printf "${YELLOW}\nFetching repository...${NOCOLOR}\n\n"

git config --global init.defaultBranch master
git init
git config advice.detachedHead false
git config http.version HTTP/1.1
git remote add origin ${REPOSITORY_URL}

git --config-env=http.extraheader=GIT_HTTP_EXTRAHEADER fetch \
  --depth=1 --force --no-tags \
  origin ${REPOSITORY_BRANCH_NAME}

EXIT_CODE=$?

if [ $EXIT_CODE == 0 ]; then
  printf "${GREEN}Done!${NOCOLOR}\n"
else
  echo -e "\n----------------------------------------"
  #echo " Error: git fetch error"
  printf "${RED}Error: git fetch error${NOCOLOR}\n"
  echo "----------------------------------------"
  cat ${ERROR_FILE}
  exit $EXIT_CODE
fi

printf "${YELLOW}\nSwitching to branch ${REPOSITORY_BRANCH_NAME}${NOCOLOR}\n\n"

git switch --force --progress ${REPOSITORY_BRANCH_NAME}
EXIT_CODE=$?

if [ $EXIT_CODE == 0 ]; then
  printf "${GREEN}Done!${NOCOLOR}\n"
else
  echo -e "\n----------------------------------------"
  #echo " Error: git checkout error"
  printf "${RED}Error: git checkout error${NOCOLOR}\n"
  echo "----------------------------------------"
  cat ${ERROR_FILE}
  exit $EXIT_CODE
fi

if [ ! -d "${TMP_DIR}/${REPOSITORY_TEST_FOLDER}" ]; then
  echo "Error: directory ${REPOSITORY_TEST_FOLDER} doesn't exist in branch ${REPOSITORY_BRANCH_NAME}"
  exit 1022
fi

if [ $(find ${TMP_DIR}/${REPOSITORY_TEST_FOLDER} -type f -name "${REQUIRED_FILE_PATTERN}" | wc -l) -eq 0 ]; then
  echo "Error: required files ${REQUIRED_FILE_PATTERN} don't exist in branch ${REPOSITORY_BRANCH_NAME}"
  exit 1024
fi

cp -r ${TMP_DIR}/${REPOSITORY_TEST_FOLDER}/* ${OUTPUT_FOLDER}

echo -e "\n----------------------------------------"
echo " Files"
echo -e "----------------------------------------\n"
tree ${OUTPUT_FOLDER}
echo "----------------------------------------"
