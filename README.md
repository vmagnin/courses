# Script courses.sh : Courses Assistées par Ordinateur

Ce script bash a pour objectif de vous aider à :

* trouver un créneau de livraison quand ils se font rares,
* surveiller la disponibilité des articles en rupture de stock.

## Installation

Clonez le dépôt GitHub ou téléchargez et extrayez le zip dans un répertoire.

Pour profiter pleinement des fonctionnalités d'alerte du script, il vous faudra installer les paquets suivants (commande pour Ubuntu) :

```
$ sudo apt install firefox espeak-ng mbrola-fr1 kdeconnect sox
```

* eSpeak NG et MBROLA sont utilisés pour la synthèse vocale.
* La commande `play` permettant de jouer un son fait partie de SoX.
* KDE Connect permet de lancer des alertes sur votre mobile. Il vous faudra pour cela aussi installer l'application KDE Connect sur votre mobile à partir de l'un de ces dépôts  puis à partir de celle-ci associer votre mobile et votre ordinateur :
    * https://play.google.com/store/apps/details?id=org.kde.kdeconnect_tp&hl=fr_FR
    * https://f-droid.org/fr/packages/org.kde.kdeconnect_tp/
* Il est également possible de lancer des alertes par email. Il vous faudra installer et configurer un serveur SMTP, par exemple ssmtp.

Vous pouvez bien sûr également supprimer ces commandes si vous ne souhaitez pas installer certains paquets : en particulier, si vous n'êtes pas sous KDE, vous pouvez par exemple ne pas souhaiter installer KDE Connect et ses nombreuses dépendances.

Références :

* https://github.com/espeak-ng/espeak-ng
* http://sox.sourceforge.net/
* https://kdeconnect.kde.org/


## Configuration

Pour chaque enseigne à surveiller, créez un fichier `courses_enseigne.sh` (remplacer bien sûr ici `enseigne` par le nom de l'enseigne !) sur le modèle de `courses_defaut.sh` et paramétrez-le :

* `intervalle` : intervalle en minutes entre les recherches.
* `id_mobile` : identifiant KDE Connect de votre téléphone portable ou tablette. Vous pouvez l'obtenir avec la commande `kdeconnect-cli -l`.
* `courriel` : votre adresse e-mail si vous voulez être averti ainsi (nécessite un serveur SMTP).
* `url_site` : URL de la page d'accueil du site à surveiller.
* `url_reservation_creneau` : URL permettant d'accéder directement à la page de réservation de créneau pour gagner du temps. Si cette page n'existe pas, mettez la page d'accueil du site.
* `cookie` : cookie d'identification. Pour l'obtenir, dans Firefox (ou Chromium), allez dans le menu *Développement web > Réseau* et rechargez la page. Avec le bouton droit de la souris, cliquez sur la racine du site et sélectionnez *Copier > Copier comme cURL.* Collez cette commande curl dans un terminal et simplifiez-la au maximum. Par exemple, dans le cas du site houra.fr, le cookie d'identification contiendra juste un identifiant du type `ID=1b4385f2422c36d3`. Mais pour le site Chronodrive.com, il faudra les chaînes `chronoShop`, `chronoUser` et `chronoSecure`.
* `commande_en_cours` : URL permettant d'accéder directement à la page d'une commande en cours. On peut éventuellement y mettre plusieurs URL séparées par une espace.
* Si vous utilisez ce script avec d'autres enseignes, il vous faudra analyser les pages web ou leur code source pour trouver les chaînes de caractères qu'il faudra chercher. Pour éviter les problèmes de codage de caractères, mieux vaut éviter les accents dans les termes recherchés : par exemple, plutôt que "créneau disponible", on cherchera "neau disponible" ou simplement "disponible". Il faudra également vous assurer qu'il n'y a pas de risque de fausse alerte avec ces chaînes. **Merci de partager ces chaînes en postant un message dans l'onglet [Issues](https://github.com/vmagnin/courses/issues) !**
    * `chaine_creneau_disponible` : chaîne (de préférence sans caractère accentué) permettant de détecter que des créneaux de livraison sont disponibles.
    * `chaine_article_disponible` : chaîne  (de préférence sans caractère accentué) permettant de détecter qu'un article est disponible. Une analyse du code HTML peut être nécessaire : regardez comment est défini le bouton permettant d'acheter l'article.
* `surveiller_creneaux` : booléen indiquant s'il faut aussi surveiller la disponibilité des créneaux de livraison. Une fois un créneau réservé, on mettra ce paramètre à `false` et on relancera le script afin de ne surveiller que les articles manquants.
* `liste_articles` : noms des variables contenant les URL des articles à surveiller, séparés par des espaces.
* `houra_pain_de_mie` : exemple de nom de variable contenant l'URL d'un article à surveiller. Bien nommer ces variables est important car leur nom sera utilisé dans les messages d'alerte (y compris par synthèse vocale). Sur certains sites, les produits en rupture de stock n'apparaissent pas dans les rayons, mais on peut trouver leur URL en cherchant dans un moteur de recherche telle que Qwant ou Google avec l'opérateur 
`site:`, par exemple :

```
    "vitamine c" site:houra.fr
```

### Paramètres pour quelques enseignes

#### chronodrive

```
readonly url_site='https://www.chronodrive.com/home'
readonly cookie='Cookie: chronoShop="shopId=blablabla"; chronoUser="userId=blablabla"; chronoSecure="token=blablabla"; madeMeOptinCloseWidgetNewsletter=1; madeMeOptinCloseWidgetNewsletterNbClose=1; headerInfoClosed=1'
readonly chaine_creneau_disponible='Dispo.'
readonly chaine_article_disponible='Ajouter au panier'
```

#### houra.fr

Voir les paramètres du fichier `courses_defaut.sh`. Pour `chaine_article_disponible`, on recherche "AcheterArticle(" plutôt que "AcheterArticle" car on trouve parfois sur la même page des propositions d'articles "associés" avec un bouton défini ainsi :

```
<button type="button" onclick="AcheterArticleAsso('FormAchat_1404805')" title="Ajouter l'article au panier" class="btn small rouge">Acheter</button>
```


## Utilisation

Une fois définie votre configuration, il n'y a plus qu'à lancer le script dans une fenêtre de terminal.
Si vous ne spécifiez aucune enseigne en lançant le script, le fichier `courses_defaut.sh` sera utilisé. Pour utiliser un autre fichier de configuration, indiquer le nom de l'enseigne en paramètre :

```
$ ./courses.sh enseigne
```

Si vous voulez être alerté par votre mobile, n'oubliez pas d'y lancer au préalable l'application KDE Connect. Le message envoyé au lancement du script permet de vérifier que la connexion est effective.

### Aspects éthiques

L'utilisateur a la responsabilité de ne pas participer à la surcharge des serveurs, en particulier dans les moments de crise. Pour cela, on choisira une valeur raisonnable pour la constante `intervalle` (par défaut 15 minutes) et on ne lancera le script que quand nécessaire, avec uniquement la recherche des articles vraiment nécessaires.

### Lancement différé du script

Pour lancer le script à une heure précise, vous pouvez utiliser la commande `at`, par exemple :

```
$ echo "DISPLAY=:0 konsole -e ./courses.sh enseigne" | at 08:00
```
Le script sera ici lancé dans le terminal Konsole de KDE. La variable d'environnement `DISPLAY` est indispensable si vous voulez voir apparaître la fenêtre à l'écran !


## Aspects techniques

### Options des commandes

#### curl

* `-s` : permet de supprimer les messages de curl *(silent).*
* `-H` : permet d'ajouter un en-tête *(header)* à la requête HTTPS, contenant par exemple le cookie d'identification.

#### grep

* `-a` : au cas où le fichier texte contient des éléments "binaires" ou des caractères de fin de ligne de type Windows.
* `-o` : n'affiche que la chaîne trouvée, et non pas toute la ligne.

#### echo

* `-e` : permet l'interprétation des séquences d'échappement (`\n` en particulier).
* `-n` : supprime le passage à la ligne en fin de chaîne.

#### play

* `-q` : supprime l'affichage *(quiet).*

#### espeak-ng

* `-v` : nom de la voix utilisée. Nous utilisons ici les voix MBROLA qui sonnent beaucoup moins synthétiques que la voix robotique de espeak-ng.
* `-s` : vitesse en mots par minute.

#### kdeconnect-cli

* `--refresh` : cherche les périphériques disponibles et rétablit les connexions.
* `--device` : identifiant du périphérique.
* `--ping-msg` : message textuel à envoyer.
* `--ping` : envoie d'un ping.
* `--ring` : fait sonner le mobile.

### Double substitution

La ligne suivante permet de faire une double substitution de variable en bash :

```
eval "url=\${${article}}"
```

Voir https://unix.stackexchange.com/questions/68042/double-and-triple-substitution-in-bash-and-zsh

### Vérification par ShellCheck

La syntaxe de ce script a été vérifiée avec l'utilitaire `shellcheck`. La directive `# shellcheck source=./courses_defaut.sh` est nécessaire car l'utilitaire ne peut pas interpréter le nom du fichier de configuration importé dans le script par la ligne `. courses_"${enseigne}".sh`.
