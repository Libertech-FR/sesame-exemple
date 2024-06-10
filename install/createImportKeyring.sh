#!/bin/bash
yarn console keyrings create >/tmp/key 2>/dev/null <<FIN
import
FIN
cat /tmp/key|grep "Keyring created successfully"|cut -f4 -d " "
rm -rf /tmp/key
