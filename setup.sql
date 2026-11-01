-- Run this once in Supabase: SQL Editor -> New query -> paste -> Run.
create table if not exists public.books (
  id         text primary key,
  name       text not null,
  data       jsonb not null,
  version    integer not null default 1,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.books enable row level security;

-- Only signed-in users you create can read or change the books.
create policy "signed-in users can read"   on public.books for select to authenticated using (true);
create policy "signed-in users can add"    on public.books for insert to authenticated with check (true);
create policy "signed-in users can update" on public.books for update to authenticated using (true) with check (true);

-- Added later: lets signed-in users delete a company (the app asks for confirmation and downloads a backup first).
create policy "signed-in users can delete" on public.books for delete to authenticated using (true);
