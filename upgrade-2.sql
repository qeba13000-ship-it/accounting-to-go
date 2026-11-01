-- UPGRADE 2: who-can-edit roles + history of changes.
-- Run this ONCE in Supabase: SQL Editor -> New query -> paste everything -> Run.

-- 1) Who may edit. Anyone not listed here can only VIEW.
create table if not exists public.members (
  email text primary key,
  role  text not null default 'viewer' check (role in ('editor','viewer'))
);
alter table public.members enable row level security;
create policy "read own role" on public.members for select to authenticated
  using (lower(email) = lower(auth.jwt() ->> 'email'));

-- Everyone who already has a login keeps full editing rights.
insert into public.members (email, role)
  select lower(email), 'editor' from auth.users
  on conflict (email) do nothing;

-- 2) Only editors may change the books (this is enforced by the database itself).
drop policy if exists "signed-in users can add"    on public.books;
drop policy if exists "signed-in users can update" on public.books;
drop policy if exists "signed-in users can delete" on public.books;

create policy "editors can add" on public.books for insert to authenticated
  with check (exists (select 1 from public.members m where lower(m.email) = lower(auth.jwt() ->> 'email') and m.role = 'editor'));
create policy "editors can update" on public.books for update to authenticated
  using      (exists (select 1 from public.members m where lower(m.email) = lower(auth.jwt() ->> 'email') and m.role = 'editor'))
  with check (exists (select 1 from public.members m where lower(m.email) = lower(auth.jwt() ->> 'email') and m.role = 'editor'));
create policy "editors can delete" on public.books for delete to authenticated
  using (exists (select 1 from public.members m where lower(m.email) = lower(auth.jwt() ->> 'email') and m.role = 'editor'));

-- 3) History of who changed what.
create table if not exists public.audit (
  id      bigint generated always as identity primary key,
  at      timestamptz not null default now(),
  who     text not null,
  company text,
  action  text not null,
  detail  text
);
alter table public.audit enable row level security;
create policy "everyone signed in can read history" on public.audit for select to authenticated using (true);
create policy "write history as yourself" on public.audit for insert to authenticated
  with check (lower(who) = lower(auth.jwt() ->> 'email'));
