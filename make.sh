#!/bin/sh

if [ "$1" == "" ]
then
    echo USAGE: $0 '<program name>'
    exit 1
fi

echo "Setting vars..."

PROGRAM_NAME=$1
APPLECOMMANDER="./makelib/AppleCommander.jar"
DISK_IMAGE_SOURCE="./makelib/prodos_template.dsk"
DISK_IMAGE_DESTINATION="$PROGRAM_NAME".dsk
LOADERFILE="$PROGRAM_NAME".SYSTEM
TARGETFILE=`basename $PROGRAM_NAME`

#Assemble
echo "Assembling and linking..."
ca65 "$PROGRAM_NAME".s -l "$PROGRAM_NAME"-listing.txt --target apple2
ld65 "$PROGRAM_NAME".o -o "$PROGRAM_NAME" -C linker.config --dbgfile "$PROGRAM_NAME"-debug.txt

echo "Packaging disk image..." 

cp "$DISK_IMAGE_SOURCE" "$DISK_IMAGE_DESTINATION"

#rename loader (copies then deletes)
java -jar "$APPLECOMMANDER" -g "$DISK_IMAGE_DESTINATION" LOADER.SYSTEM | java -jar "$APPLECOMMANDER" -p "$DISK_IMAGE_DESTINATION" "$LOADERFILE" sys
java -jar "$APPLECOMMANDER" -d "$DISK_IMAGE_DESTINATION" LOADER.SYSTEM

#delete unused stuff
java -jar "$APPLECOMMANDER" -d "$DISK_IMAGE_DESTINATION" BASIC.SYSTEM
java -jar "$APPLECOMMANDER" -d "$DISK_IMAGE_DESTINATION" NS.CLOCK.SYSTEM

#copy program
java -jar "$APPLECOMMANDER" -p "$DISK_IMAGE_DESTINATION" "$TARGETFILE" "bin" "0x800" < "$PROGRAM_NAME"

echo "Cleaning up..."
rm "$PROGRAM_NAME".o
rm "$PROGRAM_NAME"

echo "Created disk image: ./$DISK_IMAGE_DESTINATION."
