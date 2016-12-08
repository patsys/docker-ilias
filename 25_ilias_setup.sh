#!/bin/sh
file=$ILIAS_HTDOCS/index.php
sqlfile=$ILIAS_HTDOCS/setup/sql/ilias3.sql

cd $ILIAS_HTDOCS
if [ ! -f "$file" ] || [ `wc -c <"$file"` -le 100 ]; then
  durl=`lynx -dump -hiddenlinks=listonly  http://www.ilias.de/docu/goto.php?target=lm_1719\&client_id=docu | grep -o -e "http.*.tar.gz"`
  wget $durl
  filename=`ls *.tar.gz`
  version=`echo "${filename%.tar.gz}" | grep -o -e "[0-9].*[0-9]"`
  filename="ILIAS-$version"
  ln -s . $filename
  tar  -xzf v*.tar.gz $filename
  rm $filename
  rm *.tar.gz
  mkdir ../iliasdata && chown -R apache:apache ../iliasdata

  if [ ! -z $ILIAS_CREATE_CONFIG ] ; then
    cp setup/ilias.master.ini.php ilias.ini.php

    ILIAS_ZIP_PATH=`which zip`
    ILIAS_UNZIP_PATH=`which unzip`   
    ILIAS_JAVA_PATH=`which java`  
    ILIAS_FFMPEG_PATH=`which ffmpeg`
    ILIAS_SETUP_PASSWORD=`echo -n "$ILIAS_SETUP_PASSWORD" | md5sum | cut -d ' ' -f 1`
    [ -z $ILIAS_DATADIR_PATH ] && ILIAS_DATADIR_PATH=`readlink -m ../iliasdata` 
    sed -i '/^\[server\]$/,/^\[/s#http_path =,*#http_path = "'"$ILIAS_HTTP_PATH"'"#g' ilias.ini.php
    sed -i '/^\[server\]$/,/^\[/s#absolute_path =.*#absolute_path = "'"$ILIAS_HTDOCS"'"#g' ilias.ini.php
    sed -i '/^\[clients\]$/,/^\[/s#datadir =.*#datadir = "'"$ILIAS_DATADIR_PATH"'"#g' ilias.ini.php
    sed -i '/^\[clients\]$/,/^\[/s#default =.*#default = "'"$ILIAS_CLIENT_NAME"'"#g' ilias.ini.php
    sed -i '/^\[setup\]$/,/^\[/s#pass =.*#pass = "'"$ILIAS_SETUP_PASSWORD"'"#g' ilias.ini.php
    [ ! -z "$ILIAS_CONVERT_PATH" ] && sed -i '/^\[tools\]$/,/^\[/s#convert =.*#convert = "'"$ILIAS_CONVERT_PATH"'"#g' ilias.ini.php
    sed -i '/^\[tools\]$/,/^\[/s#zip =#zip = "'"$ILIAS_ZIP_PATH"'"#g' ilias.ini.php
    sed -i '/^\[tools\]$/,/^\[/s#unzip =.*#unzip = "'"$ILIAS_UNZIP_PATH"'"#g' ilias.ini.php
    [ ! -z $ILIAS_JAVA_PATH ] && sed -i '/^\[tools\]$/,/^\[/s#java =.*#java = "'"$ILIAS_JAVA_PATH"'"#g' ilias.ini.php
    [ ! -z $ILIAS_HTMLDOCR_PATH ] && sed -i '/^\[tools\]$/,/^\[/s#htmldoc =.*#htmldoc = "'"$ILIAS_HTMLDOC_PATH"'"#g' ilias.ini.php
    [ ! -z $ILIAS_FFMPEG_PATH ] && sed -i '/^\[tools\]$/,/^\[/s#ffmpeg =.*#ffmpeg = "'"$ILIAS_FFMPEG_PATH"'"#g' ilias.ini.php  
    if [ ! -z $ILIAS_LOG_PATH ] && [ ! -z "$ILIAS_LOG_FILE" ] ; then
      sed -i '/^\[log\]/,/^\[/s#path =.*#path = "'"$ILIAS_LOG_PATH"'"#g' ilias.ini.php
      sed -i '/^\[log\]/,/^\[/s#file =.*#file = "'"$ILIAS_LOG_FILE"'"#g' ilias.ini.php
      sed -i '/\[log\]/,/^\[/s#enabled = 0#enabled = "1"#g' ilias.ini.php
    else
      sed -i '/\[log\]/,/^\[/s#enabled = 1#enabled = "0"#g' ilias.ini.php
    fi

    if [ ! -z $ILIAS_LOG_LEVEL ] ; then
      sed -i '/^\[log\]/,/^\[/s#level =.*#level = "'"$ILIAS_LOG_LEVEL"'"#g' ilias.ini.php
    fi

    sed -i -e 's#\(.* = \)\([^"]*\)$#\1"\2"#' ilias.ini.php 


    if grep -q "'common','admin_firstname',''" $sqlfile ; then
      sed -i "s/('common','admin_firstname','')/('common','admin_firstname','$ILIAS_ADMIN_FIRSTNAME')/g" $sqlfile
    else   
      sed -i "s/('common','inst_name',''),/('common','inst_name',''),('common','admin_firstname','$ILIAS_ADMIN_FIRSTNAME'),/g" $sqlfile
      sed -i "s/('common','inst_name','');/('common','inst_name','');\nINSERT INTO \`settings\` VALUES ('common','admin_firstname','$ILIAS_ADMIN_FIRSTNAME');/g" $sqlfile
    fi

    if grep -q "'common','admin_lastname',''" $sqlfile ; then
      sed -i "s/('common','admin_lastname','')/('common','admin_lastname','$ILIAS_ADMIN_LASTNAME')/g" $sqlfile
    else   
      sed -i "s/('common','inst_name',''),/('common','inst_name',''),('common','admin_lastname','$ILIAS_ADMIN_LASTNAME'),/g" $sqlfile
      sed -i "s/('common','inst_name','');/('common','inst_name','');\nINSERT INTO \`settings\` VALUES ('common','admin_lastname','$ILIAS_ADMIN_LASTNAME');/g" $sqlfile
    fi

    if grep -q "'common','admin_email',''" $sqlfile ; then
      sed -i "s/('common','admin_email','')/('common','admin_email','"$ILIAS_ADMIN_EMAIL"')/g" $sqlfile
    else   
      sed -i "s/('common','inst_name',''),/('common','inst_name',''),('common','admin_email','"$ILIAS_ADMIN_EMAIL"'),/g" $sqlfile
      sed -i "s/('common','inst_name','');/('common','inst_name','');\nINSERT INTO \`settings\` VALUES ('common','admin_email','"$ILIAS_ADMIN_EMAIL"');/g" $sqlfile
    fi

    if grep -q "'common','nic_enabled',''" $sqlfile ; then
      sed -i "s/('common','nic_enabled','')/('common','nic_enabled','0')/g" $sqlfile
    else
      sed -i "s/('common','inst_name',''),/('common','inst_name',''),('common','nic_enabled','0'),/g" $sqlfile
      sed -i "s/('common','inst_name','');/('common','inst_name','');\nINSERT INTO \`settings\` VALUES ('common','nic_enabled','0');/g" $sqlfile
    fi

    if grep -q "'common','setup_ok',''" $sqlfile ; then
      sed -i "s/('common','setup_ok','')/('common','setup_ok','1')/g" $sqlfile
    else
      sed -i "s/('common','inst_name',''),/('common','inst_name',''),('common','setup_ok','1'),/g" $sqlfile
      sed -i "s/('common','inst_name','');/('common','inst_name','');\nINSERT INTO \`settings\` VALUES ('common','setup_ok','1');/g" $sqlfile
    fi


    sed -i "s/('common','inst_name','')/('common','inst_name','"$ILIAS_CLIENT_NAME"')/g" $sqlfile
    
    mysql $ILIAS_DB_NAME -h $ILIAS_DB_HOST -u $ILIAS_DB_USER -p$ILIAS_DB_PASSWORD < "$sqlfile"

    mkdir -p data/$ILIAS_CLIENT_NAME/
    mkdir -p data/$ILIAS_CLIENT_NAME/css/  data/$ILIAS_CLIENT_NAME/lm_data/  data/$ILIAS_CLIENT_NAME/mobs/ data/$ILIAS_CLIENT_NAME/usr_images/
    mkdir -p $ILIAS_DATADIR_PATH/$ILIAS_CLIENT_NAME/files/   $ILIAS_DATADIR_PATH/$ILIAS_CLIENT_NAME/forum/   $ILIAS_DATADIR_PATH/$ILIAS_CLIENT_NAME/lm_data/ $ILIAS_DATADIR_PATH/$ILIAS_CLIENT_NAME/mail
    cp setup/client.master.ini.php data/$ILIAS_CLIENT_NAME/client.ini.php
  
    sed -i '/^\[client\]/,/^\[/s#name =.*#name = "'"$ILIAS_CLIENT_NAME"'"#g' data/$ILIAS_CLIENT_NAME/client.ini.php
    sed -i '/^\[client\]/,/^\[/s#access.*#access = "1"#g' data/$ILIAS_CLIENT_NAME/client.ini.php
    sed -i '/^\[db\]/,/^\[/s#type =.*#type = "'"$ILIAS_DB_TYPE"'"#g' data/$ILIAS_CLIENT_NAME/client.ini.php
    sed -i '/^\[db\]/,/^\[/s#host =.*#host = "'"$ILIAS_DB_HOST"'"#g' data/$ILIAS_CLIENT_NAME/client.ini.php
    sed -i '/^\[db\]/,/^\[/s#user =.*#user = "'"$ILIAS_DB_USER"'"#g' data/$ILIAS_CLIENT_NAME/client.ini.php 
    sed -i '/^\[db\]/,/^\[/s#pass =.*#pass = "'"$ILIAS_DB_PASSWORD"'"#g' data/$ILIAS_CLIENT_NAME/client.ini.php
    sed -i '/^\[db\]/,/^\[/s#name =.*#name = "'"$ILIAS_DB_NAME"'"#g' data/$ILIAS_CLIENT_NAME/client.ini.php
    [ ! -z $ILIAS_LANG ] && sed -i '/^\[language\]/,/^\[/s#default =.*#default = "'"$ILIAS_LANG"'"#g' data/$ILIAS_CLIENT_NAME/client.ini.php

    sed -i -e 's#\(.* = \)\([^"]*\)$#\1"\2"#' data/$ILIAS_CLIENT_NAME/client.ini.php 
  fi

  chown -R apache:apache ./
  chown -R apache:apache $ILIAS_DATADIR_PATH

fi
exit 0
