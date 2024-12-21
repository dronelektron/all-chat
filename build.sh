#!/bin/bash

PLUGIN_NAME="all-chat"

cd scripting
spcomp $PLUGIN_NAME.sp -o ../plugins/$PLUGIN_NAME.smx
