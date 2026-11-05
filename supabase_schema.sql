-- WOD TRACKER V2 — schéma Supabase
-- À exécuter dans Supabase > SQL Editor après création du projet.
create extension if not exists pgcrypto;
create table if not exists public.groups (
 id uuid primary key default gen_random_uuid(),
 name text not null default 'Mon groupe',
 created_at timestamptz not null default now()
);
create table if not exists public.group_members (
 group_id uuid not null references public.groups(id) on delete cascade,
 user_id uuid not null references auth.users(id) on delete cascade,
 role text not null default 'member' check(role in ('admin','member')),
 primary key(group_id,user_id)
);
create table if not exists public.profiles (
 id uuid primary key default gen_random_uuid(),
 group_id uuid not null references public.groups(id) on delete cascade,
 display_name text not null,
 owner_user_id uuid not null references auth.users(id),
 created_at timestamptz not null default now()
);
create table if not exists public.workouts (
 id uuid primary key default gen_random_uuid(),
 group_id uuid not null references public.groups(id) on delete cascade,
 profile_id uuid not null references public.profiles(id) on delete cascade,
 name text not null,
 workout_date date not null,
 format text not null default 'Autre',
 blocks text not null default '',
 notes text not null default '',
 completed boolean not null default false,
 created_at timestamptz not null default now()
);
create table if not exists public.results (
 id uuid primary key default gen_random_uuid(),
 group_id uuid not null references public.groups(id) on delete cascade,
 profile_id uuid not null references public.profiles(id) on delete cascade,
 workout_id uuid references public.workouts(id) on delete set null,
 name text not null,
 result_date date not null,
 format text not null default 'Autre',
 score text not null,
 score_type text not null default 'reps',
 unit text default '',
 notes text not null default '',
 created_at timestamptz not null default now()
);
alter table public.groups enable row level security;
alter table public.group_members enable row level security;
alter table public.profiles enable row level security;
alter table public.workouts enable row level security;
alter table public.results enable row level security;
-- Membres du groupe : lecture des données communes.
create policy "members read groups" on public.groups for select using (
 exists(select 1 from public.group_members gm where gm.group_id=id and gm.user_id=auth.uid()));
create policy "members read membership" on public.group_members for select using (
 exists(select 1 from public.group_members gm where gm.group_id=group_members.group_id and gm.user_id=auth.uid()));
create policy "members read profiles" on public.profiles for select using (
 exists(select 1 from public.group_members gm where gm.group_id=profiles.group_id and gm.user_id=auth.uid()));
create policy "admin manage profiles" on public.profiles for all using (
 exists(select 1 from public.group_members gm where gm.group_id=profiles.group_id and gm.user_id=auth.uid() and gm.role='admin'))
 with check (exists(select 1 from public.group_members gm where gm.group_id=profiles.group_id and gm.user_id=auth.uid() and gm.role='admin'));
-- Tout membre peut lire les séances et scores du groupe.
create policy "members read workouts" on public.workouts for select using (
 exists(select 1 from public.group_members gm where gm.group_id=workouts.group_id and gm.user_id=auth.uid()));
create policy "members read results" on public.results for select using (
 exists(select 1 from public.group_members gm where gm.group_id=results.group_id and gm.user_id=auth.uid()));
-- Propriétaire du profil ou administrateur : ajout/modification/suppression.
create policy "owner admin manage workouts" on public.workouts for all using (
 exists(select 1 from public.group_members gm where gm.group_id=workouts.group_id and gm.user_id=auth.uid() and
 (gm.role='admin' or exists(select 1 from public.profiles p where p.id=workouts.profile_id and p.owner_user_id=auth.uid()))))
 with check (exists(select 1 from public.group_members gm where gm.group_id=workouts.group_id and gm.user_id=auth.uid() and
 (gm.role='admin' or exists(select 1 from public.profiles p where p.id=workouts.profile_id and p.owner_user_id=auth.uid()))));
create policy "owner admin manage results" on public.results for all using (
 exists(select 1 from public.group_members gm where gm.group_id=results.group_id and gm.user_id=auth.uid() and
 (gm.role='admin' or exists(select 1 from public.profiles p where p.id=results.profile_id and p.owner_user_id=auth.uid()))))
 with check (exists(select 1 from public.group_members gm where gm.group_id=results.group_id and gm.user_id=auth.uid() and
 (gm.role='admin' or exists(select 1 from public.profiles p where p.id=results.profile_id and p.owner_user_id=auth.uid()))));
-- IMPORTANT : création initiale du groupe, adhésion et profil administrateur
-- à effectuer via une fonction sécurisée / étape d'installation dédiée.
