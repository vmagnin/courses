#! /bin/bash
# Script pour surveiller les sites de courses
# Vincent MAGNIN, 22 mars 2020
# Licence GNU GPL v3
# Dernière modification le 01-05-2020
#
# Paramètres du script :
# ${1}    Enseigne à surveiller
#
# Vérifié avec $ shellcheck ./courses_defaut.sh ./courses.sh
# shellcheck source=./courses_defaut.sh

# Détection des variables non déclarées :
set -u

# Inclure les paramètres de l'enseigne fournie ou de celle par défaut :
readonly enseigne=${1:-'defaut'}
if [ -f courses_"${enseigne}".sh ] ; then
    . courses_"${enseigne}".sh
    echo "Surveillance de l'enseigne ${enseigne} : ${url_site}"
else
    echo "Enseigne ${enseigne} inconnue !"
    exit 1
fi

# Son à utiliser pour l'alerte :
readonly son='/usr/share/sounds/Oxygen-Im-Phone-Ring.ogg'

echo 'Connexion au mobile'
kdeconnect-cli --refresh
kdeconnect-cli --device "${id_mobile}" --ping-msg "./courses.sh ${enseigne}"

# Cherche une chaîne dans une page html avec curl :
# ${1}    Chaîne à chercher
# ${2}    URL à visiter
# ${3}    Options de curl -H (pour les cookies)
# Renvoie le résultat de la (dernière) commande
function chercher_curl() {
    if [ ${#} -eq 2 ]; then
        curl -s "${2}" | grep -a -o --colour "${1}"
    elif  [ ${#} -eq 3 ]; then
        curl -s "${2}" -H "${3}" | grep -a -o --colour "${1}"
    else
        echo ">>>>>> chercher_curl() : nb d'arguments incorrect"
        exit 2 ;
    fi
}

# Lance l'alerte et le navigateur :
# ${1}    URL à lancer
# ${2}    Message d'alerte
# ${3}    Nombre de répétitions
function alerter() {
    echo ">>>>>> ${2} ${1}"
    echo -n ">>> ${2} " >> courses.log
    # Pour être averti par courriel (nécessite par exemple ssmtp) :
    #echo ">>>>>> ${2} ${1}" | mail -s './courses.sh' "${courriel}"

    # Ouvrir l'URL :
    firefox --new-tab "${1}" &

    # Alerte sur le téléphone portable s'il est connecté :
    if kdeconnect-cli --device "${id_mobile}" --ping 2> /dev/null; then
        kdeconnect-cli --device "${id_mobile}" --ping-msg "${2}"
        kdeconnect-cli --device "${id_mobile}" --ring
    else
        echo ">>> mobile ${id_mobile} non connecté..."
    fi

    # Avertissements sonores :
    for i in $(seq 1 "${3}") ; do 
        AUDIODRIVER=alsa play -q "${son}"
        espeak-ng -v french-mbrola-1 -s 125 "${2}"
    done
}

# Boucle infinie :
while :
do
    # Affichage de la date et de l'heure :
    date_heure=$(date +%c | sed 's/ CEST//')
    echo -e "\n---- ${date_heure} ----"

    # On teste si on est connecté à internet :
    if host "${url_site}" | grep --colour SERVFAIL ; then
        echo ">>> Problème d'accès internet, nouvel essai dans une minute..."
        sleep 1m
        continue    # Force l'itération suivante du while
    fi

    # Ecriture dans le journal :
    echo -en "\n${date_heure}    " >> courses.log

    # Recherche de créneaux horaires :
    if [ "${surveiller_creneaux}" = true ] ; then
        echo -en "\n>>> Recherche créneaux ${enseigne} : "
        if chercher_curl "${chaine_creneau_disponible}" "${url_site}" "${cookie_creneaux}" ; then
            alerter "${url_reservation_creneau}" "Créneau ${enseigne} !" 10
        fi
    fi

    # Recherche d'articles spécifiques :
    nb_articles=0
    for article in ${liste_articles} ; do
        # On récupère le contenu de la variable dont le nom est dans article :
        url="${!article}"

        echo -en "\n>>> Recherche ${article} : "

        if chercher_curl "${chaine_article_disponible}" "${url}" "${cookie_articles}" ; then
            if [ ${nb_articles} -eq 0 ]; then
                # On ouvre la (les) commande(s) en cours. Pas de guillemets ici
                # afin de pouvoir ouvrir éventuellement plusieurs commandes :
                firefox --new-tab ${commande_en_cours} &
            fi

            nb_articles=$((nb_articles+1))
            alerter "${url}" "${article} !" 3
        fi ;
     done

    # On attend avant de recommencer :
    echo -e "\n... Pause de ${intervalle} minutes"
    sleep "${intervalle}m"
done    # Fin de la boucle infinie (à interrompre avec CTRL+C)
