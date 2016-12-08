#!/bin/sh
if [ ! -f /utils/.props/moodle_version.md5 ]; then 
  durl=`lynx -dump -hiddenlinks=listonly http://download.moodle.org/releases/latest/ | grep -m 1  -o -e "http://.*org/stable.*.*tgz.md5"`
  wget -O /utils/.props/moodle_version.md5 $durl
else
  durl=`lynx -dump -hiddenlinks=listonly http://download.moodle.org/releases/latest/ | grep -m 1  -o -e "http://.*org/stable.*.*tgz.md5"`
  wget -O /utils/.props/test_moodle_version.md5 $durl
  org=`cat /utils/.props/moodle_version.md5`
  tes=`cat /utils/.props/test_moodle_version.md5`
  rm /utils/.props/test_moodle_version.md5
  if [ ! "$org"="$tes" ]; then
    echo "moodle update exist"
    exit 1
  fi
fi
exit 0
