#! /bin/bash
# Paramètres pour le site de courses
# Vincent MAGNIN, 22 mars 2020
# Licence GNU GPL v3
# Dernière modification le 24-04-2020

# Intervalle en minutes entre les recherches :
readonly intervalle=15

# Pour les alertes :
readonly id_mobile='blablabla'
readonly courriel='prenom.nom@fai.fr'

# URL et cookie d'identification du site de courses à surveiller :
readonly url_site='https://www.houra.fr/'
readonly url_reservation_creneau='https://www.houra.fr/com/reservation_creneau.php'
readonly cookie='Cookie: ID=blablablablablabla'

# URL de l'éventuelle commande en cours :
readonly commande_en_cours='https://www.houra.fr/cpt/index.php?c=commandes-en-cours&id_commande=blablablabla'

# Chaînes à chercher :
readonly chaine_creneau_disponible='Livraison possible'
readonly chaine_article_disponible='AcheterArticle('

# Faut-il surveiller les créneaux disponibles ?
readonly surveiller_creneaux=true
#readonly surveiller_creneaux=false

# Liste des articles à surveiller :
readonly liste_articles='houra_pain_de_mie houra_oeufs'

# URL des articles
readonly houra_pain_de_mie='https://www.houra.fr/catalogue/produits-frais/boulangerie/pain-de-mie-B1508036-1.html'
readonly houra_oeufs='https://www.houra.fr/catalogue/produits-frais/oeufs-B1451873-1.html'
