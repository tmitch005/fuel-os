-- Fuel OS — Supabase schema
-- Run in Supabase Dashboard → SQL Editor → New query → Run
--
-- Before running:
-- 1. Create a project at https://supabase.com
-- 2. Authentication → Providers → enable Email (magic link is fine)
-- 3. Run this entire file
-- 4. Copy config.example.js → config.js with your Project URL + anon key

-- One row per user: mirrors localStorage key fuelos_v2 (foods, logs, templates, targets, viewDate)
create table if not exists public.user_states (
  user_id uuid primary key references auth.users (id) on delete cascade,
  data jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

create index if not exists user_states_updated_at_idx
  on public.user_states (updated_at desc);

alter table public.user_states enable row level security;

create policy "select own state"
  on public.user_states for select
  using (auth.uid() = user_id);

create policy "insert own state"
  on public.user_states for insert
  with check (auth.uid() = user_id);

create policy "update own state"
  on public.user_states for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "delete own state"
  on public.user_states for delete
  using (auth.uid() = user_id);

-- Auto-create empty state row when someone signs up
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.user_states (user_id, data)
  values (new.id, '{}'::jsonb)
  on conflict (user_id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();
