-- SPOTIMAE : catalogue partagé réservé aux comptes authentifiés.
-- Exécuter dans Supabase Dashboard > SQL Editor.

create table if not exists public.tracks (
  id uuid primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  artist text not null,
  album text,
  year integer,
  genre text,
  lyrics text,
  lyric_lines jsonb not null default '[]'::jsonb,
  audio_path text not null,
  cover_path text,
  favorite boolean not null default false,
  original_name text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint tracks_year_check check (year is null or year between 1900 and 2100)
);

-- Migration pour les projets qui ont déjà créé la table avant la synchronisation des paroles.
alter table public.tracks add column if not exists lyric_lines jsonb not null default '[]'::jsonb;

create index if not exists tracks_user_created_idx on public.tracks(user_id, created_at desc);
alter table public.tracks enable row level security;
revoke all on public.tracks from anon;
grant select, insert, update, delete on public.tracks to authenticated;

drop policy if exists "Users can read their own tracks" on public.tracks;
drop policy if exists "Authenticated users can read shared tracks" on public.tracks;
create policy "Authenticated users can read shared tracks" on public.tracks for select to authenticated using (true);
drop policy if exists "Users can insert their own tracks" on public.tracks;
create policy "Users can insert their own tracks" on public.tracks for insert to authenticated with check ((select auth.uid()) = user_id);
drop policy if exists "Users can update their own tracks" on public.tracks;
create policy "Users can update their own tracks" on public.tracks for update to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
drop policy if exists "Users can delete their own tracks" on public.tracks;
create policy "Users can delete their own tracks" on public.tracks for delete to authenticated using ((select auth.uid()) = user_id);

-- Profil utilisateur : nom, prénom et chemin de la photo dans Storage.
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text,
  first_name text not null default '',
  last_name text not null default '',
  avatar_path text,
  updated_at timestamptz not null default now()
);
alter table public.profiles add column if not exists username text;
create unique index if not exists profiles_username_unique_idx on public.profiles (lower(username)) where username is not null and username <> '';
alter table public.profiles enable row level security;
revoke all on public.profiles from anon;
grant select, insert, update on public.profiles to authenticated;
drop policy if exists "Users can read their own profile" on public.profiles;
create policy "Users can read their own profile" on public.profiles for select to authenticated using ((select auth.uid()) = id);
drop policy if exists "Users can insert their own profile" on public.profiles;
create policy "Users can insert their own profile" on public.profiles for insert to authenticated with check ((select auth.uid()) = id);
drop policy if exists "Users can update their own profile" on public.profiles;
create policy "Users can update their own profile" on public.profiles for update to authenticated using ((select auth.uid()) = id) with check ((select auth.uid()) = id);

-- Activer les changements en direct pour les bibliothèques ouvertes sur d'autres appareils.
do $$ begin
  if not exists (select 1 from pg_publication_tables where pubname='supabase_realtime' and schemaname='public' and tablename='tracks') then
    alter publication supabase_realtime add table public.tracks;
  end if;
  if not exists (select 1 from pg_publication_tables where pubname='supabase_realtime' and schemaname='public' and tablename='profiles') then
    alter publication supabase_realtime add table public.profiles;
  end if;
end $$;
alter table public.tracks replica identity full;
alter table public.profiles replica identity full;

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('spotimae-media', 'spotimae-media', false, 52428800,
  array['audio/mpeg','audio/wav','audio/x-wav','image/jpeg','image/png','image/webp','image/gif'])
on conflict (id) do update set public=false, file_size_limit=52428800,
  allowed_mime_types=excluded.allowed_mime_types;

drop policy if exists "Users can read their own Spotimae files" on storage.objects;
drop policy if exists "Authenticated users can read shared Spotimae files" on storage.objects;
create policy "Authenticated users can read shared Spotimae files" on storage.objects for select to authenticated
  using (bucket_id='spotimae-media');
drop policy if exists "Users can upload their own Spotimae files" on storage.objects;
create policy "Users can upload their own Spotimae files" on storage.objects for insert to authenticated
  with check (bucket_id='spotimae-media' and (storage.foldername(name))[1]=(select auth.uid()::text));
drop policy if exists "Users can update their own Spotimae files" on storage.objects;
create policy "Users can update their own Spotimae files" on storage.objects for update to authenticated
  using (bucket_id='spotimae-media' and (storage.foldername(name))[1]=(select auth.uid()::text))
  with check (bucket_id='spotimae-media' and (storage.foldername(name))[1]=(select auth.uid()::text));
drop policy if exists "Users can delete their own Spotimae files" on storage.objects;
create policy "Users can delete their own Spotimae files" on storage.objects for delete to authenticated
  using (bucket_id='spotimae-media' and (storage.foldername(name))[1]=(select auth.uid()::text));
