# SPOTIMAE — configuration Supabase

Le site fonctionne hors compte avec une bibliothèque locale. Les utilisateurs connectés partagent un catalogue cloud : lorsqu’un compte ajoute un morceau, son fichier et ses métadonnées sont téléversés dans Supabase puis les autres appareils connectés au catalogue le récupèrent automatiquement. Les morceaux importés avant cette fonction restent locaux et ne sont pas envoyés rétroactivement.

## 1. Créer le projet Supabase

1. Crée un projet dans le tableau de bord Supabase.
2. Dans **SQL Editor**, exécute le contenu actualisé de `supabase-schema.sql`. Cela crée `public.tracks` et `public.profiles`, ajoute le nom d’utilisateur unique, configure les permissions du catalogue partagé, ajoute ces tables à Supabase Realtime et crée le bucket `spotimae-media`.
3. Dans **Project Settings → API**, copie l’URL du projet et la clé publique **publishable** (ou legacy `anon`). Ne prends jamais `service_role`.
4. Colle ces deux valeurs dans `supabase-config.js` :

```js
window.SPOTIMAE_SUPABASE_URL = 'https://TON-PROJET.supabase.co';
window.SPOTIMAE_SUPABASE_ANON_KEY = 'sb_publishable_...';
```

La clé publishable/anon est prévue pour le navigateur, mais la sécurité des données dépend des policies RLS créées par le SQL. La clé `service_role` ne doit jamais être placée dans le site.

## 2. E-mail / mot de passe

Dans **Authentication → URL Configuration**, ajoute l’URL du site aux **Redirect URLs**. Pour un site hébergé, utilise son URL HTTPS. Vérifie le réglage de confirmation d’e-mail ; si la confirmation est active, l’utilisateur doit valider son e-mail avant la première connexion.

## 3. Connexion Google

Dans **Authentication → Sign In / Providers → Google**, active le fournisseur et renseigne le **Client ID** et le **Client Secret** créés dans Google Cloud Console. Dans Google, ajoute l’URL de callback affichée par Supabase (`https://<project-ref>.supabase.co/auth/v1/callback`) comme URI de redirection autorisée. Ajoute également l’URL HTTPS du site SPOTIMAE dans les Redirect URLs de Supabase.

## 3 bis. Connexion Discord

1. Dans le [Discord Developer Portal](https://discord.com/developers/applications), crée une application SPOTIMAE, ouvre **OAuth2** et ajoute l’URL de callback affichée par Supabase dans **Redirects**. Elle a la forme `https://<project-ref>.supabase.co/auth/v1/callback` ; pour ce projet, copie la valeur exacte affichée dans Supabase.
2. Dans Supabase → **Authentication → Sign In / Providers → Discord**, active Discord. Copie le **Client ID** et le **Client Secret** de Discord dans les champs correspondants de Supabase, puis enregistre.
3. Dans Supabase → **Authentication → URL Configuration**, garde `https://spotimae.vercel.app/` dans **Redirect URLs** et cette adresse comme **Site URL**. Le retour de connexion utilise l’adresse de l’application.
4. Publie les changements du site sur GitHub/Vercel. Dans **Mon compte**, le bouton **Continuer avec Discord** sera alors visible.

Le Client Secret Discord doit rester dans Supabase. Ne le colle pas dans `supabase-config.js`, dans un autre fichier du site ou dans GitHub. Le code appelle Supabase Auth avec le fournisseur `discord` ; aucune modification SQL n’est nécessaire.

## 4. Publier le site sur Vercel

SPOTIMAE est un site statique : il n’a pas de compilation, de commande d’installation ou de serveur Node à lancer sur Vercel.

1. Mets les fichiers du dossier dans un dépôt GitHub (si besoin, crée un dépôt puis téléverse les fichiers du projet).
2. Dans Vercel, choisis **Add New → Project**, connecte GitHub et importe ce dépôt.
3. Dans la configuration du projet, choisis **Other** comme Framework Preset, laisse **Build Command** vide et indique `.` comme **Output Directory**. Ne mets pas de commande d’installation.
4. Clique **Deploy**. Vercel fournit une adresse HTTPS en `*.vercel.app`. Ouvre-la et vérifie que la page se charge.
5. Dans Vercel → projet → **Settings → Domains**, ajoute ton propre domaine si tu en as un. Après chaque changement envoyé sur la branche de production du dépôt, Vercel republie le site.

### Relier l’adresse Vercel à Supabase

1. Dans Supabase → **Authentication → URL Configuration**, mets l’adresse publique choisie comme **Site URL**, par exemple `https://spotimae.vercel.app`.
2. Dans **Redirect URLs**, ajoute exactement `https://spotimae.vercel.app/` (et l’adresse de ton domaine personnalisé si tu en ajoutes un). Pour les aperçus Vercel facultatifs, ajoute `https://*-<identifiant-equipe>.vercel.app/**`. Garde `http://localhost:3000/**` seulement si tu l’utilises en développement ; le serveur local de ce projet utilise actuellement le port 8080, donc ajoute aussi `http://localhost:8080/**` si tu testes les confirmations e-mail ou Google OAuth en local.
3. Dans Google Cloud Console, garde comme **Authorized redirect URI** l’URL de callback donnée par Supabase, sous la forme `https://<project-ref>.supabase.co/auth/v1/callback`. Cette adresse reste celle de Supabase ; ce n’est pas l’URL Vercel. L’adresse du site, elle, est autorisée dans les Redirect URLs de Supabase.
4. Recharge le site déployé, connecte-toi à un compte puis importe un morceau. Il est ajouté automatiquement au catalogue partagé. Sur un autre appareil, connecte-toi à SPOTIMAE et le catalogue se charge automatiquement.

### Synchronisation et profil

Si tu as déjà exécuté une ancienne version de `supabase-schema.sql`, réexécute le fichier complet depuis le **SQL Editor** pour configurer le catalogue accessible aux comptes connectés, l’accès aux fichiers audio partagés, ajouter `profiles.username` et son index unique, et activer Realtime. Les morceaux locaux préexistants ne sont pas envoyés automatiquement.

Une fois connecté, l’ajout d’un morceau téléverse son audio et ses métadonnées sur Supabase. Tous les comptes connectés peuvent consulter et écouter les morceaux du catalogue partagé ; Realtime les avertit des ajouts et suppressions et chaque appareil télécharge les fichiers automatiquement. Les suppressions restent réservées au compte qui a ajouté le morceau.

La session Supabase est conservée dans le stockage local du navigateur. Sur un autre navigateur ou appareil, reconnecte-toi avec le même compte Google (même adresse Google) pour accéder à ce compte ; les sessions ne sont pas partagées entre navigateurs.

Dans **Mon compte → Mon profil**, le nom d’utilisateur SPOTIMAE, le prénom et le nom sont conservés dans `public.profiles`; le nom d’utilisateur apparaît dans l’application à la place du nom du fournisseur OAuth. La photo est enregistrée dans le bucket privé. Le mot de passe n’est jamais placé dans cette table ni dans le profil : Supabase Auth le met à jour de manière sécurisée. Un compte créé avec Google peut ajouter un mot de passe depuis son profil, puis utiliser l’e-mail et ce mot de passe pour se connecter.

Le code contient déjà l’URL Supabase et la clé **publishable** du navigateur dans `supabase-config.js`. Cette clé est conçue pour être publique ; les policies RLS du SQL et le bucket privé contrôlent l’accès aux données. N’ajoute jamais une clé `service_role` ou le secret OAuth Google aux fichiers du site ou au dépôt. N’efface pas `supabase-config.js` pendant le déploiement.

La bibliothèque locale IndexedDB reste liée au navigateur/appareil où les morceaux ont été importés. Pour les écouter sur un autre appareil, connecte-toi au même compte Supabase et synchronise les morceaux depuis l’appareil d’origine.

## Ce que fait l’application

- Création de compte et connexion par e-mail/mot de passe.
- Connexion Google via Supabase OAuth.
- Connexion Discord via Supabase OAuth (à activer avec les identifiants du Discord Developer Portal).
- Bibliothèque partagée entre les comptes connectés, fichiers servis par un bucket privé réservé aux utilisateurs authentifiés.
- Les comptes connectés peuvent lire les morceaux et les fichiers du catalogue partagé ; seul le compte qui a ajouté un morceau peut le modifier ou le supprimer.
- Les morceaux préexistants restent locaux sur leur appareil et ne sont pas transférés rétroactivement.
- La clé secrète `service_role` n’est jamais utilisée côté navigateur.


## Paroles synchronisées

La synchronisation ligne par ligne est stockée dans `public.tracks.lyric_lines` (JSONB). Si la table a été créée avant cette fonction, exécute à nouveau le SQL de migration inclus à la fin de `supabase-schema.sql` dans le SQL Editor.
