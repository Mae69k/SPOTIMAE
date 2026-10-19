# SPOTIMAE — configuration Supabase

Le site fonctionne encore hors compte avec une bibliothèque locale. Le compte Supabase ajoute une bibliothèque cloud privée, synchronisée entre appareils. Après connexion, les nouveaux morceaux sont téléversés dans le bucket privé. Les morceaux locaux déjà présents ne sont envoyés que si l’utilisateur appuie sur « Synchroniser mes morceaux locaux » et confirme.

## 1. Créer le projet Supabase

1. Crée un projet dans le tableau de bord Supabase.
2. Dans **SQL Editor**, exécute le contenu de `supabase-schema.sql`. Cela crée `public.tracks`, active les politiques RLS par utilisateur et crée le bucket privé `spotimae-media` avec une limite de 50 Mo par fichier.
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
4. Recharge le site déployé, crée/connecte un compte, puis importe un morceau. L’application téléverse les nouveaux morceaux dans le bucket privé. Les morceaux déjà enregistrés dans le navigateur doivent être envoyés explicitement avec **Mon compte → Synchroniser mes morceaux locaux**.

Le code contient déjà l’URL Supabase et la clé **publishable** du navigateur dans `supabase-config.js`. Cette clé est conçue pour être publique ; les policies RLS du SQL et le bucket privé contrôlent l’accès aux données. N’ajoute jamais une clé `service_role` ou le secret OAuth Google aux fichiers du site ou au dépôt. N’efface pas `supabase-config.js` pendant le déploiement.

La bibliothèque locale IndexedDB reste liée au navigateur/appareil où les morceaux ont été importés. Pour les écouter sur un autre appareil, connecte-toi au même compte Supabase et synchronise les morceaux depuis l’appareil d’origine.

## Ce que fait l’application

- Création de compte et connexion par e-mail/mot de passe.
- Connexion Google via Supabase OAuth.
- Bibliothèque cloud et fichiers audio/pochettes dans un bucket privé.
- Les policies limitent chaque ligne et chaque fichier au propriétaire du compte.
- Les morceaux préexistants restent locaux tant que l’utilisateur ne lance pas la synchronisation manuelle.
- La clé secrète `service_role` n’est jamais utilisée côté navigateur.


## Paroles synchronisées

La synchronisation ligne par ligne est stockée dans `public.tracks.lyric_lines` (JSONB). Si la table a été créée avant cette fonction, exécute à nouveau le SQL de migration inclus à la fin de `supabase-schema.sql` dans le SQL Editor.
