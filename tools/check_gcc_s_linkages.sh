#!/bin/bash

GCC_S=`ldd /usr/lib/*.so 2>&1 | grep -v warning | \
    awk '/^\//{LIB=$1;} /libstdc/{LIB=""} /gcc_s/{if(LIB){print LIB;}}' | \
    grep -v gcc_s | cut -f1 -d:`
GCC_S_64=`ldd /usr/lib/amd64/*.so 2>&1 | grep -v warning | \
    awk '/^\//{LIB=$1;} /libstdc/{LIB=""} /gcc_s/{if(LIB){print LIB;}}' | \
    grep -v gcc_s | cut -f1 -d:`

CPLUSPLUS=`ldd /usr/lib/{,amd64/}*.so 2>&1 | grep -v warning | \
    awk '/^\//{LIB=$1;} /libstdc\+\+/{print LIB;}' | \
    grep -v 'libstdc++' | cut -f1 -d:`

echo "G++ runtime (libstdc++.so) dependent libs:"
echo "=================================================================="
if [[ -n "$CPLUSPLUS" ]]; then
    for so in $CPLUSPLUS; do
        echo "\t$so"
    done
fi

echo
echo "GCC runtime (libgcc_s.so) dependentlibs (exluding C++):"
echo "=================================================================="
if [[ -n "$GCC_S" ]]; then
    for so in $GCC_S; do
        echo "\t$so"
    done
fi

declare -A gcc_s_sym
for sym in `nm /usr/lib/libgcc_s.so | \
        sed -e 's/ *//g;' | \
        awk -F\| '{if($5=="GLOB" && $4=="FUNC" && $7!="UNDEF"){print $8;}}'`; do
    gcc_s_sym+=([$sym]=1)
done
for sym in `nm /usr/lib/libc.so | \
        sed -e 's/ *//g;' | \
        awk -F\| '{if($5=="GLOB" && $4=="FUNC" && $7!="UNDEF"){print $8;}}'`; do
    unset gcc_s_sym[$sym]
done

declare -A gcc64_s_sym
for sym in `nm /usr/lib/amd64/libgcc_s.so | \
        sed -e 's/ *//g;' | \
        awk -F\| '{if($5=="GLOB" && $4=="FUNC" && $7!="UNDEF"){print $8;}}'`; do
    gcc64_s_sym+=([$sym]=1)
done
for sym in `nm /usr/lib/amd64/libc.so | \
        sed -e 's/ *//g;' | \
        awk -F\| '{if($5=="GLOB" && $4=="FUNC" && $7!="UNDEF"){print $8;}}'`; do
    unset gcc64_s_sym[$sym]
done

echo
echo "Libraries with unresolved symbols from libgcc_s:"
echo "=================================================================="
for so in /usr/lib/*.so; do
    [[ "$so" = "/usr/lib/libstdc++.so" ]] && continue
    syms=""
    for sym in `nm $so | sed -e 's/ *//g;' | \
            awk -F\| '{if($5=="GLOB" && $7=="UNDEF"){print $8;}}'`; do
        if [[ -n ${gcc_s_sym[$sym]} ]]; then
            syms="$sym $syms"
        fi
    done
    if [[ -n "$syms" ]]; then
        echo "\t$so: $syms"
    fi
done
for so in /usr/lib/amd64/*.so; do
    [[ "$so" = "/usr/lib/amd64/libstdc++.so" ]] && continue
    syms=""
    for sym in `nm $so | sed -e 's/ *//g;' | \
            awk -F\| '{if($5=="GLOB" && $7=="UNDEF"){print $8;}}'`; do
        if [[ -n ${gcc64_s_sym[$sym]} ]]; then
            syms="$sym $syms"
        fi
    done
    if [[ -n "$syms" ]]; then
        echo "\t$so: $syms"
    fi
done

