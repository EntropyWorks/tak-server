#!/usr/bin/env bash
# Makes an ATAK / iTAK friendly data package containing CA, user cert, user key
if [ $# -eq 0 ]
  then
    echo "No arguments supplied. Need an IP and a user eg. ./certDP.sh 192.168.0.2 user1"
    exit
fi

IP=$1
USERNAME=$2

generate_uuid(){
    cat /dev/urandom \
        | tr -dc 'a-f0-9' \
        | fold -w 32 | head -n 1 \
        | sed -E 's/^(.{8})(.{4})(.{4})(.{4})(.{12})$/\1-\2-\3-\4-\5/'
}

echo "#---------------------------------"
echo "# ${USERNAME} ${IP}"
echo "# $(pwd)"
echo "#---------------------------------"

# server.pref

echo "<?xml version='1.0' encoding='ASCII' standalone='yes'?>" > server.pref
echo "<preferences>" >> server.pref
echo "  <preference version=\"1\" name=\"cot_streams\">" >> server.pref
echo "    <entry key=\"count\" class=\"class java.lang.Integer\">1</entry>" >> server.pref
echo "    <entry key=\"description0\" class=\"class java.lang.String\">TAK Server</entry>" >> server.pref
echo "    <entry key=\"enabled0\" class=\"class java.lang.Boolean\">true</entry>" >> server.pref
echo "    <entry key=\"connectString0\" class=\"class java.lang.String\">${IP}:8089:ssl</entry>" >> server.pref
echo "  </preference>" >> server.pref
echo "  <preference version=\"1\" name=\"com.atakmap.app_preferences\">" >> server.pref
echo "    <entry key=\"displayServerConnectionWidget\" class=\"class java.lang.Boolean\">true</entry>" >> server.pref
echo "    <entry key=\"caLocation\" class=\"class java.lang.String\">cert/${IP}.p12</entry>" >> server.pref
echo "    <entry key=\"caPassword\" class=\"class java.lang.String\">atakatak</entry>" >> server.pref
echo "    <entry key=\"clientPassword\" class=\"class java.lang.String\">atakatak</entry>" >> server.pref
echo "    <entry key=\"certificateLocation\" class=\"class java.lang.String\">cert/${USERNAME}.p12</entry>" >> server.pref
echo "  </preference>" >> server.pref
echo "</preferences>" >> server.pref


# manifest.xml



echo "<MissionPackageManifest version=\"2\">" > manifest.xml
echo "  <Configuration>" >> manifest.xml
echo "    <Parameter name=\"uid\" value=\"$(generate_uuid)\"/>" >> manifest.xml
echo "    <Parameter name=\"name\" value=\"${USERNAME} DP\"/>" >> manifest.xml
echo "    <Parameter name=\"onReceiveDelete\" value=\"true\"/>" >> manifest.xml
echo "  </Configuration>" >> manifest.xml
echo "  <Contents>" >> manifest.xml
echo "    <Content ignore=\"false\" zipEntry=\"certs\\server.pref\"/>" >> manifest.xml
echo "    <Content ignore=\"false\" zipEntry=\"certs\\${IP}.p12\"/>" >> manifest.xml
echo "    <Content ignore=\"false\" zipEntry=\"certs\\${USERNAME}.p12\"/>" >> manifest.xml
echo "  </Contents>" >> manifest.xml
echo "</MissionPackageManifest>" >> manifest.xml

zip -j /opt/tak/certs/files/${USERNAME}-${IP}.dp.zip \
  manifest.xml \
  server.pref \
  /opt/tak/certs/files/${IP}.p12 \
  /opt/tak/certs/files/${USERNAME}.p12

rm -f manifest.xml server.pref

echo "-------------------------------------------------------------"
echo "Created certificate data package for ${USERNAME} @ ${IP} as /opt/tak/certs/files/${USERNAME}-${IP}.dp.zip"
