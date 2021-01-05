# canarie-bro-logs
**CANARIE JSP BRO Logs Upload Script**

The [canarie-bro-logs-setup.sh](canarie-bro-logs-setup.sh) script configures your CANARIE JSP server to upload your local BRO logfiles to a remote CANARIE JSP aggregation site. Once installed, it uses `rsync` over `ssh` to allow for a secure and incremental logfiles upload.

By default, it only uploads `conn` and `notice` BRO logfiles, and only if they were created `today` or `yesterday`.

## Installation

Download [canarie-bro-logs-setup.sh](https://raw.githubusercontent.com/ontkanin/canarie_jsp/master/canarie-bro-logs/canarie-bro-logs-setup.sh) to your BRO server, and run it as follows:

```
sh canarie-bro-logs-setup.sh
```

The script creates two files:

* `/usr/local/bin/canarie-bro-logs.sh`, which is the actual upload script
* `/etc/cron.d/canarie-bro-logs.cron`, which is a cronjob file running the upload script

## Configuration

Once installed, you need to modify the upload script to match your environment

Edit `SETTINGS` section in `/usr/local/bin/canarie-bro-logs.sh`:

* `SSH_ACCOUNT`: your SSH account name; replace `EDIT-THIS`
* `SSH_IP`: IP address of the aggregation site; default: `push.jointsecurity.ca`
* `SSH_PORT`: SSH port of the aggregation site; default: `56320`
* `BRO_LOGS_DIR`: location of your BRO logfiles; default `/srv/bro/logs`
* `BRO_LOGS`: BRO log types to upload (logfile names without their file extension); default: `conn` and `notice`
* `RSYNC_LOG`: location for `rsync` transaction log; default: `/var/log/canarie/rsync.log`

In order to configure `BRO_LOGS`, you can list all BRO log types on your server by running the following command, where `/srv/bro/logs` is the location of your BRO logfiles:

```
find /srv/bro/logs -type f | awk -F/ '{print $NF}' | cut -d. -f1 | sort -u
```
```
capture_loss
communication
conn
conn-summary
dce_rpc
dhcp
dns
dpd
files
ftp
http
irc
kerberos
known_certs
known_hosts
known_services
meta
modbus
mysql
notice
ntlm
pe
radius
rdp
reporter
rfb
sip
smtp
snmp
socks
software
ssh
ssl
stats
syslog
tunnel
weird
x509
```

Once configured, set `ENABLE_UPLOAD=1` to enable the upload.

## Usage


Once installed, configured and enabled, the upload script runs once an hour via crontab. If needed, you can control that in `/etc/cron.d/canarie-bro-logs.cron`

The script expects a passwordless private SSH key on the local server and its respective public SSH key already deployed to the aggregation site. Please see [SSH Passwordless Login Using SSH Keygen in 5 Easy Steps](https://www.tecmint.com/ssh-passwordless-login-using-ssh-keygen-in-5-easy-steps/) for help with passwordless SSH keys.
