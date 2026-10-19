# SPOTIMAE

SPOTIMAE est une Progressive Web App (PWA) de bibliothèque musicale personnelle. Elle fonctionne dans le navigateur et peut être ajoutée à l’écran d’accueil d’Android ou d’iPhone.

## Démarrer sur l’ordinateur

Windows : lancer `DEMARRER-SPOTIMAE.bat`, puis ouvrir `http://localhost:8080`.

Ou dans PowerShell, depuis le dossier du projet :

```powershell
node server.js
```

Puis ouvrir `http://localhost:8080`.

## Ouvrir sur un téléphone du même Wi-Fi

Lancer `DEMARRER-SPOTIMAE.bat`, noter l’adresse réseau affichée dans la fenêtre, puis saisir cette adresse dans le navigateur du téléphone. L’ordinateur doit rester allumé et connecté pendant l’accès. Sur certains téléphones, l’installation PWA nécessite HTTPS ; pour un accès permanent, héberger ces fichiers sur un service statique HTTPS (par exemple GitHub Pages ou Netlify).

## Installation sur l’écran d’accueil

- Android / Chrome : menu ⋮ → « Installer l’application » ou « Ajouter à l’écran d’accueil ».
- iPhone / Safari : Partager → « Sur l’écran d’accueil ».

Les morceaux et leurs informations sont conservés dans le stockage privé local de SPOTIMAE (IndexedDB, géré par le navigateur qui héberge l’application). Ils ne sont pas envoyés au serveur. La PWA ne peut pas écrire directement dans le stockage privé des fichiers système d’iOS ou Android. Effacer les données du site ou désinstaller l’application peut effacer la bibliothèque ; garde les fichiers originaux en sauvegarde.

## Fonctions présentes

Import MP3/WAV avec formulaire intégré (titre, artiste, album, année, genre, pochette et paroles), lecture, précédent/suivant, barre de progression, recherche, favoris, lecture en arrière-plan via Media Session quand le système le permet, logo/icônes Android et iPhone, cache hors ligne de l’interface.

Paroles synchronisées : import LRC ou calage gratuit en écoutant le morceau et en marquant le début de chaque ligne. Le minutage est conservé dans la bibliothèque locale et Supabase. Aucun service d’IA automatique n’est utilisé.


## Comptes et bibliothèque cloud

Voir [README-SUPABASE.md](README-SUPABASE.md) pour connecter un projet Supabase, créer le schéma SQL sécurisé et activer l’authentification e-mail/Google. Tant que les identifiants publics du projet ne sont pas inscrits dans `supabase-config.js`, la connexion reste volontairement désactivée.
"# SPOTIMAE" 
