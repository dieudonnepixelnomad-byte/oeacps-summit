Cahier des charges fonctionnel — Application mobile (POC statique)
1) Contexte & objectif
1.1 Objectif principal

Créer une application mobile officielle de type “Sommet / événement institutionnel”, qui :

présente les informations clés (programme, intervenants, actualités, média, infos, contact),

simule un parcours d’accréditation et un “badge / QR code”,

fonctionne sans backend (tout statique + données fictives),

reste crédible et démontrable pour partenaires/institutions.

1.2 Contraintes de la V1 (POC statique)

Aucun backend

Aucune API

Toutes les pages alimentées par des données fictives (embarquées)

Les actions “soumettre”, “télécharger”, “envoyer”, “contact” sont simulées (ou ouvrent des apps natives : téléphone, email, navigateur)

1.3 Objectifs secondaires

UX fluide, pro, institutionnelle

Structure prête à évoluer vers une V2 connectée (API, accréditation réelle, push, etc.)

Gestion FR/EN (statique)

2) Périmètre fonctionnel
2.1 Sections visibles dans tes écrans (périmètre inclus)

Accueil

Programme / Agenda

Intervenants

Actualités

Média (photos/vidéos)

Infos / À propos

Contact & Assistance

Accréditation (formulaire)

Confirmation (demande reçue)

Badge / QR Code (simulation)

Profil (même si POC, on garde un écran simple)

2.2 Hors périmètre (V1)

Authentification réelle (email/OTP/SSO)

Envoi de données vers un prestataire

Upload réel de documents vers serveur

Notifications push réelles (on peut simuler en UI)

Admin backoffice

3) Navigation & structure globale
3.1 Navigation principale (Bottom Bar)

D’après tes écrans, on observe plusieurs variantes de tab bar selon les sections. Pour une V1 propre :

Proposition unifiée (recommandée)

Accueil

Programme

Actualités

Intervenants

Infos / Profil

Pourquoi : éviter les tab bars différentes d’un écran à l’autre (ça donne une impression “app inachevée” et ça déstabilise).

3.2 Navigation secondaire

Bouton retour (AppBar)

Recherche (icône loupe) dans Actualités / Média / Intervenants

Filtres (icône filtre) dans Programme / Intervenants / Média

Favoris (icône bookmark) sur les cards Programme / Intervenants

4) Écrans & spécifications détaillées
4.1 Écran — Accueil

Référence visuelle : écran “Accueil” avec hero image, CTA “S’accréditer maintenant”, menu rapide.

Contenu

Hero (image + overlay)

Titre : nom de l’événement, lieu, dates

Badge “OFFICIEL”

Bloc “Inscription ouverte…” + CTA principal “S’accréditer maintenant”

Menu rapide (cards) :

Informations Sommet

Programme

Ressources Média

Lieu & Logistique

Icône notification (cloche) : page notifications (POC)

Interactions / Use cases

UC-A1 : l’utilisateur ouvre l’app → arrive sur Accueil

UC-A2 : clique “S’accréditer maintenant” → ouvre Formulaire Accréditation

UC-A3 : clique une entrée du menu rapide → ouvre la page correspondante

UC-A4 : clique cloche → ouvre “Notifications” (statique)

Données fictives

Dates, ville/pays, message institutionnel, image bannière

Liste des items menu rapide

4.2 Écran — Programme / Agenda

Référence visuelle : “Programme Officiel”, tabs Jour 1/2/3, timeline (heure à gauche), cards sessions, bouton “Télécharger le Programme (PDF)”.

Composants

Tabs jours (Jour 1, Jour 2, Jour 3…)

Liste chronologique (heure début/fin à gauche)

Card session :

Tag type (Session plénière / Débat / Workshop)

Titre

Lieu (icône location)

Intervenants (avatars + “+2”)

Bookmark (favori)

CTA bas : “Télécharger le Programme (PDF)”

Interactions / Use cases

UC-P1 : changer de jour → liste se met à jour (local)

UC-P2 : cliquer une session → ouvre “Détail Session” (à créer)

UC-P3 : cliquer bookmark → ajoute aux favoris (local)

UC-P4 : cliquer “Télécharger PDF” → ouvre un PDF local (ou lien web fictif)

Écran à ajouter — Détail Session (obligatoire pour cohérence)

Contenu recommandé :

Titre + type

Horaires + lieu

Description longue

Liste des intervenants (cliquables)

Bouton “Ajouter aux favoris”

4.3 Écran — Intervenants

Référence visuelle : liste avec barre recherche “Rechercher par nom, pays…”, section “À la une”, cards intervenants, bouton “Contact”, icônes (web/infos), bookmark.

Composants

Search bar

Filtre (icône en haut)

Section “À la une” + “Voir tout”

Cards intervenants :

Photo + drapeau

Nom (tronqué)

Fonction

Organisation

Bouton “Contact”

Icône web / profil

Bookmark

Interactions / Use cases

UC-I1 : recherche par nom → filtre la liste localement

UC-I2 : recherche par pays → filtre localement

UC-I3 : “Voir tout” → page liste complète (si “À la une” n’affiche qu’une sélection)

UC-I4 : cliquer un intervenant → page Détail Intervenant

UC-I5 : cliquer “Contact” → ouvre page Contact (ou modal contact)

UC-I6 : bookmark → favoris local

Écran à ajouter — Détail Intervenant

Photo

Nom + titre

Organisation + pays

Bio courte

Sessions associées (liens vers Détail Session)

Boutons : Email / Site / Ajouter favoris

⚠️ Dans la V1 statique, on évite d’afficher des emails personnels réels. On met des valeurs fictives.

4.4 Écran — Actualités (liste)

Référence visuelle : header “Actualités”, card à la une (image + titre + date + temps lecture + CTA “Lire l’article”), liste “Dernières actualités”.

Composants

Header + search

Bloc “À la une”

Liste articles :

Catégorie (Accords / Logistique / Conférence…)

Temps lecture

Titre

Miniature

CTA “Lire la suite”

Interactions / Use cases

UC-N1 : rechercher un article (local)

UC-N2 : cliquer “Lire l’article” → ouvre Détail Article

UC-N3 : cliquer une catégorie (si cliquable) → filtre local

4.5 Écran — Actualité (détail)

Référence visuelle : grande image, tag catégorie, date, titre, contenu, citation, “Articles similaires”.

Composants

Hero image

Métadonnées : catégorie, date

Titre + contenu long

Bloc citation (mise en avant)

Liste “Articles similaires”

Interactions / Use cases

UC-ND1 : partager (icône share)

UC-ND2 : ouvrir un article similaire

UC-ND3 : retour à la liste

4.6 Écran — Média (Photos / Vidéos)

Référence visuelle : onglets “PHOTOS / VIDÉOS”, filtres “Sommet Jour1 / Jour2 / Clôture / Archives”, grille de cards avec images.

Composants

Tabs Photos / Vidéos

Segmented filters (Jour 1, Jour 2, …)

Grille (2 colonnes) :

image

titre

heure + lieu

Interactions / Use cases

UC-M1 : passer Photos → Vidéos (local)

UC-M2 : filtrer par jour (local)

UC-M3 : cliquer une carte → ouvre détail média (photo plein écran / lecteur vidéo fictif)

Écran à ajouter — Détail Média

photo full / vidéo

titre + description

métadonnées (jour, lieu)

bouton partager

4.7 Écran — Contact & Assistance

Référence visuelle : “Contact”, sections : Secrétariat du Sommet (adresse, email), Assistance technique (téléphone, chat), Urgences & Santé (112), bouton “Envoyer une demande rapide”.

Composants & comportements (POC)

Adresse → ouvre appli Maps (ou rien si POC pur)

Email → ouvre app mail (mailto)

Téléphone → lance appel

Chat en direct :

V1 : affiche un statut “En ligne” + ouvre une page “Chat (simulation)”

Urgence 112 → bouton d’appel direct (selon OS)

“Envoyer une demande rapide” → ouvre formulaire simple (statique) + confirmation

Use cases

UC-C1 : cliquer Email → ouvre mail

UC-C2 : cliquer Téléphone → ouvre dialer

UC-C3 : cliquer Urgence → dialer + message d’alerte

UC-C4 : envoyer demande rapide → page de confirmation

4.8 Écran — À propos / Infos

Référence visuelle : “Qui sommes-nous ?” + image, texte, objectifs du sommet en liste.

Contenu

Image institutionnelle

Texte de présentation

Liste des objectifs (3+)

Éventuellement : partenaires (logos fictifs) + mentions légales

Use cases

UC-AP1 : scroller

UC-AP2 : accéder aux sections internes (ancres éventuellement)

4.9 Écran — Accréditation (Formulaire)

Référence visuelle : champs prénom/nom, nationalité (dropdown), email, téléphone, catégorie (choix), documents requis (zone upload), bouton “Envoyer la demande”.

Règles (V1 statique)

Validation locale

“Upload” simulé (ou sélection fichier local sans upload serveur)

Au clic “Envoyer la demande” :

on affiche un écran “Confirmation / Demande reçue”

on crée une “demande” localement avec un statut “En cours”

Champs minimum (V1)

Prénom (obligatoire)

Nom (obligatoire)

Nationalité (obligatoire)

Email (obligatoire + format)

Téléphone (obligatoire + format simple)

Catégorie (obligatoire : Délégué / Presse …)

Document requis :

V1 : simulateur de fichier attaché (affiche nom + taille fictive)

Use cases

UC-ACC1 : soumission valide → confirmation

UC-ACC2 : champ manquant → message d’erreur

UC-ACC3 : email invalide → message d’erreur

UC-ACC4 : “document requis absent” → blocage soumission

4.10 Écran — Confirmation “Demande reçue”

Référence visuelle : “Demande reçue”, texte, info “email sous 48h”, bouton retour accueil.

Use cases

UC-CONF1 : retour accueil

UC-CONF2 : consulter “statut” (optionnel : bouton “Suivre ma demande”)

4.11 Écran — Badge / QR Code (simulation)

Tu as une tab “Badge” sur un écran. Même sans backend, on peut le simuler proprement.

Règle

Si demande locale statut = “Validée” → afficher QR Code

Sinon → afficher message “Badge disponible après validation”

Use cases

UC-B1 : utilisateur sans demande → invite à s’accréditer

UC-B2 : statut “En cours” → badge indisponible

UC-B3 : statut “Validée” → QR visible + bouton partager

4.12 Écran — Profil (POC simple)

Même si pas d’auth réelle :

afficher un profil “Démonstration”

afficher “Mes favoris” :

sessions favoris

intervenants favoris

bouton “Réinitialiser la démo”

5) Modèles de données (obligatoires, même en statique)

On structure comme si c’était une API, pour que la V2 soit facile.

5.1 Programme
ProgramDay
- id
- label (Jour 1, Jour 2...)
- dateLabel (ex: 2 Oct)
- sessions: Session[]

Session
- id
- dayId
- type (pleniere|debat|workshop|...)
- title
- description
- startTime
- endTime
- locationName
- speakerIds[]
- isBookmarked (local)

5.2 Intervenants
Speaker
- id
- fullName
- titleRole
- organization
- countryCode
- avatarUrl (local asset)
- bio
- contactEmail (fake)
- websiteUrl (fake)
- isFeatured
- isBookmarked (local)

5.3 Actualités
NewsArticle
- id
- category
- date
- readTimeMinutes
- title
- excerpt
- content (long)
- heroImageUrl (local asset)
- quoteText (optional)
- relatedIds[]

5.4 Média
MediaItem
- id
- type (photo|video)
- tagGroup (Jour1|Jour2|Cloture|Archives)
- title
- timeLabel
- locationLabel
- coverImageUrl
- mediaUrl (local / placeholder)

5.5 Accréditation (simulation)
AccreditationRequest
- id
- firstName
- lastName
- nationality
- email
- phone
- category
- documents: FakeDocument[]
- status (pending|in_review|approved|rejected)
- createdAt

FakeDocument
- id
- filename
- fileType (pdf|jpg|png)
- sizeLabel (ex: 1.2 MB)

6) Données fictives & contenus statiques
6.1 Règles

Données stockées localement (assets / fichiers statiques)

Contenus FR & EN présents dès la V1

Images : banque d’images / placeholders (aucune image sensible)

6.2 Volume minimum recommandé (pour démo crédible)

Programme : 3 jours × 8 sessions/jour = ~24 sessions

Intervenants : 30 profils (dont 5 “À la une”)

Actualités : 10 articles (dont 1 “À la une” + 3 “similaires”/article)

Média : 20 photos + 6 vidéos (thumbnails)

7) Règles UX/UI & cohérence visuelle
7.1 Design system (d’après tes écrans)

Couleur primaire : vert institutionnel

UI “cards” arrondies + ombres légères

Chips/tags (session type, catégorie)

Boutons CTA très visibles (orange pour accréditation, vert pour téléchargements)

7.2 Bonnes pratiques à imposer

Une seule tab bar (cohérence)

États vides partout (“Aucun résultat”, “Aucun favori”, etc.)

Loading states simulés (skeletons) pour donner du réalisme

8) Contraintes qualité (même en POC)

Démarrage rapide

Fonctionne hors connexion

Pas de crash si une donnée est manquante

Navigation sans cul-de-sac (toujours un retour clair)

9) Livrables attendus (V1 statique)

Application mobile POC :

toutes pages listées

navigation complète

Données fictives structurées (FR/EN)

Modèles de données + repository local (même si statique)

Guide de démo (script) :

parcours Accueil → Programme → Session → Intervenant

parcours Accréditation → Confirmation → Badge (simulation)

Build installable (Android + iOS si demandé)