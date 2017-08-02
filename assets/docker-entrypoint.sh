#!/bin/sh

# vim: filetype=sh:tabstop=2:shiftwidth=2:expandtab

#
# Define default Variables.
#
#set -x
USER="dev"
GROUP="dev"

UID_ACTUAL=$(id -u ${USER} 2>/dev/null)
[ x"$UID_ACTUAL" = x ] && UID_ACTUAL=0
GID_ACTUAL=$(id -g ${GROUP} 2>/dev/null)
[ x"$GID_ACTUAL" = x ] && GID_ACTUAL=0

UID_NAMED=${PUID:-1100}
GID_NAMED=${PGID:-1100}

#
# Display settings on standard out.
#
#echo ""
#echo "named settings"
#echo "=============="
#echo ""
#echo "  Username:        ${USER}"
#echo "  Groupname:       ${GROUP}"
#echo "  UID actual:      ${UID_ACTUAL}"
#echo "  GID actual:      ${GID_ACTUAL}"
#echo "  UID preferred:   ${UID_NAMED}"
#echo "  GID preferred:   ${GID_NAMED}"
#echo ""

#
# Change UID / GID of named user.
#
if [ "$UID_NAMED" -ne 0 ] ; then
  l_do_work=0
  [ "$UID_ACTUAL" -ne "$UID_NAMED" ] && l_do_work=1
  [ "$GID_ACTUAL" -ne "$GID_NAMED" ] && l_do_work=1
  if [ $l_do_work -eq 1 ] ; then
    # dump the user first
    deluser "$USER" >/dev/null 2>&1

    # add the group if necessary

    if [ "$GID_ACTUAL" -ne "$GID_NAMED" ] ; then
      # delete any group owning our desired GID
      GROUP_IN_USE=$(grep -e ":$GID_NAMED:" /etc/group | awk -F':' '{print $1}')
      [ x"$GROUP_IN_USE" != x ] && delgroup $GROUP_IN_USE

      # now delete the original group (which was added by the Dockerfile)
      delgroup "$GROUP" >/dev/null 2>&1

      # and add it back with our desired name
      addgroup -g "$GID_NAMED" "$GROUP" >/dev/null 2>&1
    fi

    # now add the user back with the group
    adduser -u "$UID_NAMED" -D -H -G "$GROUP" -h /config -s /bin/bash "$USER" >/dev/null 2>&1

    # change all ownership
    find / -user "$UID_ACTUAL" -exec chown "$USER" {} \; >/dev/null 2>&1
    find / -group "$GID_ACTUAL" -exec chgrp "$GROUP" {} \; >/dev/null 2>&1
  fi
fi

# run jinja2 rendering script 
if [ "$UID_NAMED" -eq 0 ] ; then
  jinja2 "$@"
else
  sudo -E --user "$USER" jinja2 "$@"
fi

