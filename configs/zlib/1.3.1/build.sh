#!/bin/bash

BASE_DIR="$(dirname $(realpath $0))"

TARGET="src"

printf "\nBase directory: $BASE_DIR \n\n"


if [ -d "$TARGET" ]; then
	echo "The directory "$TARGET" exists. Doing nothing"
else
	echo "The directory "$TARGET" does not exist"
	exit

	#FUZZING CHANGES
	
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
	
	CFLAGS="-O0 --coverage -g" CXXFLAGS="-O0 --coverage -g" ./configure --static
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


	CC=afl-clang-fast CXX=afl-clang-fast++ ./configure --static
	make -j$(nproc)

	cd ..
fi
