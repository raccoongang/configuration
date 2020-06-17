#! /bin/sh
PATH=/sbin:/usr/sbin:${PATH}
export PATH

sudo smartctl $*
