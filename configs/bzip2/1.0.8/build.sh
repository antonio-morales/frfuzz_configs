#!/bin/bash

BASE_DIR="$(dirname $(realpath $0))"

TARGET="src"

printf "\nBase directory: $BASE_DIR \n\n"


if [ -d "$TARGET" ]; then
	echo "The directory "$TARGET" exists. Doing nothing"
else
	echo "The directory "$TARGET" does not exist"
	exit

	#CRC disable
	sed -i '830s/^/\/\//' bzlib.c
	sed -i '831s/^/\/\//' bzlib.c
	sed -i '847s/^/\/\//' bzlib.c
	sed -i '848s/^/\/\//' bzlib.c
	
fi


if [ -d "__COV" ]; then

	echo "The directory __COV exists. Doing nothing"
else
	cp -r $TARGET __COV
	if [ $? -ne 0 ]; then
		echo "Error: Failed to copy $TARGET to __COV"
		exit 1
	fi
	cd __COV
	
	sed -i 's/^LDFLAGS=/LDFLAGS=-fprofile-arcs/' Makefile
	sed -i 's/^CFLAGS=-Wall -Winline -O2/CFLAGS=-fPIC -fprofile-arcs -ftest-coverage -Wall -Winline -O0/' Makefile
	make -j$(nproc)

	cd ..

fi


if [ -d "__AFL_llvm" ]; then

	echo "The directory __AFL_llvm exists. Doing nothing"
else

	cp -r $TARGET __AFL_llvm
	if [ $? -ne 0 ]; then
	  echo "Error: Failed to copy $TARGET to __AFL_llvm"
	  exit 1
	fi
	cd __AFL_llvm

	sed -i 's/^CC=gcc/CC=afl-clang-fast/' Makefile
	make -j$(nproc)

	cd ..
fi
