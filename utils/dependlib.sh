#!/bin/bash

WINSYSDIR=`cygpath -a -u $WINDIR`

if [ ! -z "$1" ]; then
    if [ -e "$1" ]; then
        DEPEND_LIBS=`objdump --private-headers $1 | grep "DLL Name:" | sed 's/.*DLL Name: //g'`
        for i in ${DEPEND_LIBS[@]}
        do
            cygpath -a -u `which "$i"` | grep -v -i "${WINSYSDIR}/"
        done
    fi
fi
