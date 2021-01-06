#!/bin/bash
#
# Copyright 2018 Juraj Ontkanin
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

cat <<'EOF_canarie_bro_logs' > /usr/local/bin/canarie-bro-logs.sh
#!/bin/bash
#
## v2021.0105.1830

## SETTINGS ##
##

## Aggregation site settings
SSH_ACCOUNT='EDIT-THIS'
SSH_SITE='push.jointsecurity.ca'
SSH_PORT='56320'

## Local BRO log folder
BRO_LOGS_DIR='/srv/bro/logs'

## BRO log types to upload
BRO_LOGS=(
  'conn'
  'notice'
)

## RSYNC LOG settings
RSYNC_LOG='/var/log/canarie/rsync.log'

ENABLE_UPLOAD=0

##
## /SETTINGS ##

if [[ ! -d "${RSYNC_LOG%/*}" ]]; then
  if ! mkdir -p "${RSYNC_LOG%/*}"; then
    echo "-- ERROR: cannot create directory ${RSYNC_LOG%/*}" >&2
    exit 1
  fi
fi

TODAY="$( date +'%Y-%m-%d' )/"
YESTERDAY="$( date -d yesterday +'%Y-%m-%d' )/"

[[ $ENABLE_UPLOAD -eq 0 ]] && exit

BRO_LOGS_DIR="${BRO_LOGS_DIR%/}"

INCLUDE_LOGS=()
for ((i=0; i<${#BRO_LOGS[@]}; i++)); do
  INCLUDE_LOGS+=(--include="${BRO_LOGS[$i]}.*.log.gz")
done

rsync -rtve "ssh -p $SSH_PORT" --append-verify --include="$TODAY" --include="$YESTERDAY" "${INCLUDE_LOGS[@]}" --exclude="*" "${BRO_LOGS_DIR}/" ${SSH_ACCOUNT}@${SSH_SITE}:~/ >>$RSYNC_LOG
EOF_canarie_bro_logs

chmod 755 /usr/local/bin/canarie-bro-logs.sh

echo "[+] Script '/usr/local/bin/canarie-bro-logs.sh' created"

cat <<EOF_canarie_bro_logs_cron > /etc/cron.d/canarie-bro-logs.cron
SHELL=/bin/bash
PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/bin
MAILTO=root
HOME=/

$(($RANDOM%31+15)) * * * *    root  timeout 55m /usr/local/bin/canarie-bro-logs.sh
EOF_canarie_bro_logs_cron

chmod 644 /etc/cron.d/canarie-bro-logs.cron

echo "[+] Cronjob '/etc/cron.d/canarie-bro-logs.cron' created"
echo
echo "[ ] Modify '/usr/local/bin/canarie-bro-logs.sh' to match your environment"
echo
