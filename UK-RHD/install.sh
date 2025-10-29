#!/bin/ksh
# Copyright (c) 2024 LawPaul (https://github.com/LawPaul)
# This file is part of MH2p_CarPlay_Fullscreen, licensed under CC BY-NC-SA 4.0.
# https://creativecommons.org/licenses/by-nc-sa/4.0/
# See the LICENSE file in the project root for full license text.
# NOT FOR COMMERCIAL USE
# Original Author: lprot (https://github.com/lprot) (https://www.drive2.ru/users/lprot/) (from MH2p Toolbox 1.7)

touch $modPath/test.txt
if [[ ! -e $modPath/test.txt ]]; then
    echo "SD card/USB drive is write protected!"
    break
fi
rm -f $modPath/test.txt

[[ ! -e "/mnt/app" ]] && mount -t qnx6 /dev/mnanda0t177.1 /mnt/app
echo "Mounting /mnt/app in r/w mode..."
mount -uw /mnt/app

BRAND="$(grep ^OEM /mnt/app/version_info.txt | cut -d' ' -f3)"
REGION="$(grep ^Region /mnt/app/version_info.txt | cut -d' ' -f3)"
if [ "$BRAND" = "VW" ]
then
    TYPE="$(grep ^Project /mnt/app/version_info.txt | cut -d'_' -f5 | cut -d'.' -f1)"
else
    TYPE="$(grep ^HMI /mnt/app/version_info.txt | cut -d'_' -f6)"
fi

if [ "$BRAND" = "PAG" ]
then
    echo "Modding fullscreen CarPlay for Porsche PCM 5..."
    if [[ -e "/mnt/app/eso/hmi/lsd/jars" ]]; then
        if [[ -f "$modPath/fc-PCM5.jar" ]]; then
            cp -Vf $modPath/fc-PCM5.jar /mnt/app/eso/hmi/lsd/jars/fc.jar
        else
            echo "error: cannot find $modPath/fc-PCM5.jar"
        fi
    else
        echo "error: /mnt/app/eso/hmi/lsd/jars does not exist"
    fi
elif [ "$BRAND" = "AU" ]
then
    if [ "$TYPE" = "G33" ]
    then
        echo "Modding fullscreen CarPlay for Audi G33..."
        if [[ -e "/mnt/app/eso/hmi/lsd/jars" ]]; then
            if [[ -f "$modPath/fc-AUG33.jar" ]]; then
                cp -Vf $modPath/fc-AUG33.jar /mnt/app/eso/hmi/lsd/jars/fc.jar
            else
                echo "error: cannot find $modPath/fc-AUG33.jar"
            fi
        else
            echo "error: /mnt/app/eso/hmi/lsd/jars does not exist"
        fi
    elif [ "$TYPE" = "G35" ]
    then
        echo "Modding fullscreen CarPlay for Audi G35..."
        if [[ -e "/mnt/app/eso/hmi/lsd/jars" ]]; then
            if [[ -f "$modPath/fc-AUG35.jar" ]]; then
                cp -Vf $modPath/fc-AUG35.jar /mnt/app/eso/hmi/lsd/jars/fc.jar
            else
                echo "error: cannot find $modPath/fc-AUG35.jar"
            fi
        else
            echo "error: /mnt/app/eso/hmi/lsd/jars does not exist"
        fi
    else
        echo "error: Audi unknown"
    fi
elif [ "$BRAND" = "VW" ]
then
    echo "Modding fullscreen CarPlay for Volkswagen"
    [[ ! -e "/mnt/system" ]] && mount -o noatime,nosuid,noexec -r /dev/fs0p1 /mnt/system
    echo "Mounting /mnt/system/ in r/w mode..."
    mount -uw /mnt/system
    echo "setting DPI Android Auto..."
    sed -i -e s/\"dpi\":0,/\"dpi\":220,/ /mnt/system/etc/eso/production/gal.json
    if [[ -e "/mnt/app/eso/hmi/lsd/Resources/skin1" ]]; then
        if [[ ! -e $modPath/backup/skin2 ]]; then
            echo "Backing up /mnt/app/eso/hmi/lsd/Resources/skin2 to $modPath/backup/..."
            cp -rf /mnt/app/eso/hmi/lsd/Resources/skin2 $modPath/backup/
        fi
        vh_size=$(ls -l /mnt/app/eso/hmi/lsd/Resources/skin1/viewhandler.zip | awk '{print $5}' 2>/dev/null)
        if_size=$(ls -l /mnt/app/eso/hmi/lsd/Resources/skin1/info.txt | awk '{print $5}' 2>/dev/null)
            echo "Modding fullscreen CarPlay for MH2p_ER_VWG36_P2869"
            cp -Vf $modPath/viewhandler.zip /mnt/app/eso/hmi/lsd/Resources/skin2/
            cp -Vf $modPath/info.txt /mnt/app/eso/hmi/lsd/Resources/skin2/

    fi
elif [ "$BRAND" = "LB" ]
then
    echo "error: Lamborghini"
else
    echo "error: $BRAND unknown"
fi

sync
[[ -e "/mnt/app" ]] && umount -f /mnt/app
