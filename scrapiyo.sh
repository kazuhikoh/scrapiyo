#!/bin/bash

# To output MESSAGE keeping original line break,
# xmllint needs to receive a html that contains line-break character (\n) at same position as br tags.
# Because, xpath statement '/text()' extract ONLY text. 
# This formatting consist of following steps:
# 1. Remove all line-break after <br>
# 2. Append line-break after <br>
html="$(cat - | sed -e 's/<br[ /]*>/<br>\n/g')"

MESSAGE="$(echo "$html" | xmllint --xpath "//div[@class='article'][position()=1]//div[@class='article_box']/*[1]/div[@class='message_body']/text()" --html - 2>/dev/null | tr -d '\t')"

DATE=$(echo $html | xmllint --xpath "//div[@class='article'][position()=1]//div[@class='entry_date']/p/text()" --html - 2>/dev/null)

TIME=$(echo $html | xmllint --xpath "//div[@class='article'][position()=1]//div[@class='article_box']/*[1]/div[@class='message_body']/ul[@class='posted']/li[@class='time_stamp']/a/text()" --html - 2>/dev/null | tr -d '\t')

IMAGE_TAGS="$(echo $html | xmllint --xpath "//div[@class='article'][position()=1]//div[@class='article_box']/*[1]/div[@class='message_body']/img" --html - 2>/dev/null | tr -d '\t')"
IMAGE_THUMB_URL="$(echo $IMAGE_TAGS | grep -oP '(?<=src=")[^"]*(?=")' | xargs -I{} echo "http:{}")"
IMAGE_URL="$(echo $IMAGE_TAGS | grep -oP '(?<=dumy=")[^"]*(?=")' | xargs -I{} echo "http:{}")"

ANCHOR_TAGS="$(echo $html | xmllint --xpath "//div[@class='article'][position()=1]//div[@class='article_box']/*[1]/div[@class='message_body']/a" --html - 2>/dev/null)"
ANCHOR_HREFS="$(echo $ANCHOR_TAGS | grep -oP '(?<=href=")[^"]*(?=")' | xargs -I{} echo 'http://piyo.fc2.com/{}')"

print() {
  echo date $DATE
  echo time $TIME
  echo "$MESSAGE" | awk 'NF > 0 {printf("message %s\n", $0)}'
  
  if [ ! -z "$IMAGE_THUMB_URL" ]; then
    echo "$IMAGE_THUMB_URL" | awk 'NF > 0 {printf("thumb %s\n", $0)}'
  fi
  
  if [ ! -z "$IMAGE_URL" ]; then 
    echo "$IMAGE_URL" | awk 'NF > 0 {printf("image %s\n", $0)}'
  fi
  
  if [ ! -z "$ANCHOR_HREFS" ]; then
    echo "$ANCHOR_HREFS" | awk 'NF > 0 {printf("link %s\n", $0)}'
  fi
}

# diff-only output
if [ ! -z "${DIFF_FILEPATH}" ]; then
  readonly TMP_FILEPATH="${DIFF_FILEPATH}.tmp"
  print > "${TMP_FILEPATH}"

  if diff -q "${DIFF_FILEPATH}" "${TMP_FILEPATH}" >/dev/null 2>&1; then
    rm "${TMP_FILEPATH}"
    exit 1
  else
    mv "${TMP_FILEPATH}" "${DIFF_FILEPATH}"
    cat "${DIFF_FILEPATH}"
    exit 0
  fi
fi

print
