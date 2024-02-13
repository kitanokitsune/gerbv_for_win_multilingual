#!/bin/bash

if [ -z "$2" ]; then
    exit 1
fi

if [ ! -e "$1" ]; then
   exit 1
fi

if [ ! -e "$2" ]; then
   exit 1
fi

GET_DEPENDS=`dirname $0`/dependlib.sh
LIBFILES=(`${GET_DEPENDS} $1`)
RUNTIMEDLLS=()

while [ ${#LIBFILES[*]} -gt 0 ]
do
    DLLONE=${LIBFILES[0]}
    if echo "${RUNTIMEDLLS[*]}" | grep -q "${DLLONE}"; then
        true
    else
        echo "cp ${DLLONE} $2"
        cp ${DLLONE} $2
        RUNTIMEDLLS+=(${DLLONE})
        CHILD_DLLS=(`${GET_DEPENDS} ${DLLONE}`)
        while [ ${#CHILD_DLLS[*]} -gt 0 ]
        do
            DLL_1=${CHILD_DLLS[0]}
            if echo "${RUNTIMEDLLS[*]}" | grep -q "${DLL_1}"; then
                true
            elif echo "${LIBFILES[*]}" | grep -q "${DLL_1}"; then
                true
            else
                LIBFILES+=(${DLL_1})
            fi
            unset CHILD_DLLS[0]
            CHILD_DLLS=(${CHILD_DLLS[@]})
        done
    fi
    unset LIBFILES[0]
    LIBFILES=(${LIBFILES[@]})
done

