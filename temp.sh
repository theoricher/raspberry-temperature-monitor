#!/bin/bash

# Scrit original par YAVIN4 (https://yavin4.ovh/index.php/2014/12/31/raspberry-pi-recuperer-la-temperature-cpu-dans-un-fichier/)
# Script Adapté par mes soins pour envoyer des notifications TELEGRAM

token=''
chatid=''

# Récupération de la température ; on obtient ici une valeur à 5 chiffres sans virgules (ex: 44123) :
TEMP=$(cat /sys/class/thermal/thermal_zone0/temp)

# On divise alors la valeur obtenue par 1000, pour obtenir un résultat avec deux chiffres seulement (ex: 44) :
TEMP=$(($TEMP/1000))

# Récupération de la date et l'heure du jour ; on obtient ici une valeur telle que "mercredi 31 décembre 2014, 00:15:01" :
DATE=`date +"%A %d %B %Y, %H:%M:%S"`

# Récupération de la date et l'heure du jour sous un autre format ; on obtient ici un résultat sous la forme suivante : XX-YY-ZZZZ (ex: 31-12-2014) :
DATE2=`date +"%d-%m-%Y"`

# Répertoire cible (où seront stockées les valeurs). Ici je stocke mes valeurs sur mon NAS et dans un sous-répertoire portant la date du jour ($DATE2) :
REP="./$DATE2"

# Le fichier à créer dans ce répertoire est "temperature.html"
FICHIER="${REP}/temperature.html"

# Si le répertoire cible n'existe pas, on le crée
if [ ! -d "$REP" ];then
  mkdir -p "$REP"
fi

# Si le fichier temperature.html n'existe pas, on le crée et on y injecte le code html minimum
if [ ! -f "$FICHIER" ];then
  touch "$FICHIER" &&
  echo "<!DOCTYPE html><html><head><meta charset='utf-8' /></head><body><center>" > "$FICHIER"
fi


# Test de la température relevée

# Si la température relevée est inférieure à 40°C, on écrit la valeur en bleu dans le fichier :
if [ "$TEMP" -lt "40" ]; then
    echo "<font face='Courier'>${DATE}<br><strong><font color='blue'>${TEMP}°C</font></font></strong><br><br>" >> "$FICHIER"

# Si la température relevée est comprise entre +40 et 50°C, on écrit la valeur en vert dans le fichier :
elif [ "$TEMP" -ge "40" ] && [ "$TEMP" -lt "50" ];then
    echo "<font face='Courier'>${DATE}<br><strong><font color='green'>${TEMP}°C</font></font></strong><br><br>" >> "$FICHIER"

# Si la température relevée est comprise entre +50 et 70°C, on écrit la valeur en orange dans le fichier :
elif [ "$TEMP" -ge "50" ] && [ "$TEMP" -lt "70" ];then
    echo "<font face='Courier'>${DATE}<br><strong><font color='orange'>${TEMP}°C</font></font></strong><br><br>" >> "$FICHIER"

# Si la température relevée est comprise entre +70 et 75°C, on écrit la valeur en rouge dans le fichier et on envoie une alerte "surchauffe" par mail :
elif [ "$TEMP" -ge "70" ] && [ "$TEMP" -lt "75" ];then
    echo "<font face='Courier'>${DATE}<br><strong><font color='red'>${TEMP}°C</font></font></strong><br><br>" >> "$FICHIER"


msg="⚠ $(hostname): Alerte surchauffe, température : ${TEMP}°C"
curl --data chat_id=$chatid --data-urlencode "text=$msg" "https://api.telegram.org/bot$token/sendMessage" &> /dev/null
    #sudo shutdown -h now


# Si la température relevée dépasse 75°, on écrit la valeur en noir dans le fichier, on envoie une alerte par mail et on ordonne l'arrêt du RPi :
elif [ "$TEMP" -ge "75" ];then
    echo "<font face='Courier'>${DATE}<br><strong><font color='black'>${TEMP}°C</font></font></strong><br><br>" >> "$FICHIER"

msg="🚨 $(hostname): Alerte température anormale : ${TEMP}°C. Arrêt immédiat du serveur !"
curl --data chat_id=$chatid --data-urlencode "text=$msg" "https://api.telegram.org/bot$token/sendMessage" &> /dev/null
   sudo shutdown -h now

fi
exit
