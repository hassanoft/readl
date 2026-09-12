-- ============================================================================
-- READL — Schéma Supabase (V1 : authentification uniquement)
-- ============================================================================
-- À exécuter dans : Supabase Dashboard → SQL Editor.
--
-- Les tables `documents`, `reading_history`, `favorites`, `folders`,
-- `user_preferences`, `subscriptions` et `notifications` (spec section 4)
-- seront ajoutées progressivement avec les fonctionnalités correspondantes
-- (bibliothèque, historique, premium...), pour rester compilable et
-- vérifiable à chaque étape.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Table profiles
-- ----------------------------------------------------------------------------
-- Un profil par utilisateur, créé automatiquement à l'inscription par le
-- trigger `on_auth_user_created` ci-dessous.
create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  email text not null,
  first_name text not null default '',
  avatar_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists profiles_email_idx on public.profiles (email);

-- ----------------------------------------------------------------------------
-- Row Level Security — un utilisateur ne voit et ne modifie que sa propre ligne
-- ----------------------------------------------------------------------------
alter table public.profiles enable row level security;

drop policy if exists "profiles_select_own" on public.profiles;
create policy "profiles_select_own"
  on public.profiles
  for select
  using (auth.uid() = id);

drop policy if exists "profiles_update_own" on public.profiles;
create policy "profiles_update_own"
  on public.profiles
  for update
  using (auth.uid() = id)
  with check (auth.uid() = id);

-- Aucune policy INSERT/DELETE côté client : la création se fait uniquement
-- via le trigger ci-dessous (contexte serveur), la suppression via la
-- cascade sur auth.users.

-- ----------------------------------------------------------------------------
-- Trigger : crée automatiquement le profil à l'inscription
-- ----------------------------------------------------------------------------
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, email, first_name)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data ->> 'first_name', '')
  );
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row
  execute function public.handle_new_user();

-- ----------------------------------------------------------------------------
-- updated_at automatique
-- ----------------------------------------------------------------------------
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists profiles_set_updated_at on public.profiles;
create trigger profiles_set_updated_at
  before update on public.profiles
  for each row
  execute function public.set_updated_at();


-- ---------------------------------------------------------------------------
-- Documents / progression (optionnel pour la synchro cloud)
-- ---------------------------------------------------------------------------
create table if not exists public.documents (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  storage_path text,
  size_bytes bigint not null default 0,
  text_content text,
  current_page integer not null default 1,
  progress double precision not null default 0,
  favorite boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
alter table public.documents enable row level security;
drop policy if exists "documents_own_all" on public.documents;
create policy "documents_own_all" on public.documents for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create index if not exists documents_user_created_idx on public.documents(user_id, created_at desc);
