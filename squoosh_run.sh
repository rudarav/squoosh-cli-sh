#!/bin/bash

USAGE="$0 [-h <Довідка> -e --height <1200> --quality <75> -p|--path </path/to/photoes>]"

EXT=false
HEIGHT=false #1200
QUALITY=75
DIRSATE="$PWD"
BASEDIR="$PWD"

Help()
{
    # Display Help
    echo "Оптимізація розміру зображень з використанням програми Squoosh від Google"
    echo
    echo "Синтаксис: аргументи [-e|--height|-h]"
    echo
    echo "-e           Необов'язково. Змінити розширення до нижнього регістру. Якщо відсутній - файли з роширенням у верхньому регістрі не перезаписуються, а створються нові з роширенням у нижньому регістрі."
    echo "--height     Необов'язково. Висота зображення. По замовчуванню - та ж сама, що в оригіналі."
    echo "--quality    Необов'язково. Якість зображення, від 0 до 100. По замовчуванню - 75."
    echo "-p|--path    Необов'язково. Папка з фото. По замовчуванню - PWD"
    echo "-h           Надрукувати цю довідку."
    echo
}

Compress()
{
    cd $3
    
    local regext="[jJ][pP][gG]"
    
    # Якщо потрібно змінити регістр розширення
    if [[ $1 == true ]]
    then
        for f in *.JPG
        do
            mv -v -- "$f" "${f%.JPG}.jpg"
        done
        # regext=${regext,,}
        regext="jpg"
    fi
    
    
    SAVEIFS=$IFS
    IFS=$(echo -en "\n\b")
    for f in *.$regext
    do
        # Зібрати команду стиснення зображення
        cmd=(squoosh-cli)
        # Якщо потрібно змінити розмір зображення
        if [[ $2 != false ]]
        then
            cmd+=(--resize "{\"enabled\":true,\"height\":$2,\"method\":\"lanczos3\",\"fitMethod\":\"stretch\",\"premultiply\":true,\"linearRGB\":true}")
        fi
        # Основні параметри команди стиснення зображення
        cmd+=(--mozjpeg "{\"quality\":$QUALITY,\"baseline\":false,\"arithmetic\":false,\"progressive\":true,\"optimize_coding\":true,\"smoothing\":0,\"color_space\":3,\"quant_table\":3,\"trellis_multipass\":false,\"trellis_opt_zero\":false,\"trellis_opt_table\":false,\"trellis_loops\":1,\"auto_subsample\":true,\"chroma_subsample\":2,\"separate_chroma_quality\":false,\"chroma_quality\":75}" $f)
        # Запустити команду стиснення зображення
        "${cmd[@]}"
    done
    IFS=$SAVEIFS
}

while getopts ':-:p:eh' opt
do
    case $opt in
        -)
            case "${OPTARG}" in
                height) HEIGHT="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                    if [ $HEIGHT == "" ] || [ ${HEIGHT:0:1} == "-" ]
                    then
                        echo "ПОМИЛКА! Відсутнє значення аргумента --height: $USAGE"
                        exit 1
                    fi
                ;;
                quality) QUALITY="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                    if [ $QUALITY == "" ] || [ ${QUALITY:0:1} == "-" ]
                    then
                        echo "ПОМИЛКА! Відсутнє значення аргумента --quality: $USAGE"
                        exit 1
                    fi
                ;;
                path)   BASEDIR="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                    if [[ $BASEDIR == "" ]]
                    then
                        echo "ПОМИЛКА! Відсутнє значення аргумента --path: $USAGE"
                        exit 1
                    fi
                ;;
                *)      echo "ПОМИЛКА! Неприпустимий аргумент: $USAGE"
                    echo "Більше про використання скрипта: -h"
                exit 1;;
        esac;;
        e) EXT=true;;
        p) BASEDIR=$OPTARG;;
        :) echo "ПОМИЛКА! Відсутнє значення аргумента -p: $USAGE"
        exit 1;;
        h) Help
        exit;;
        \?) echo "ПОМИЛКА! Неприпустимий аргумент: $USAGE"
            echo "Більше про використання скрипта: -h"
        exit 1;;
    esac
done
Compress $EXT "$HEIGHT" "$BASEDIR"
cd $DIRSATE
