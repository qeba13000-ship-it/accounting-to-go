-- UPGRADE 5: per-company access + attachments storage.
-- Run ONCE in Supabase: SQL Editor -> New query -> paste everything -> Run.
-- Needs upgrade-2.sql to have been run first (it creates the members table).

-- 1) Who may see which company.
--    A person with NO rows in this table sees every company (nothing changes for existing users).
--    A person with rows sees ONLY the companies listed for them.
create table if not exists public.access (
  email      text not null,
  company_id text not null,
  primary key (email, company_id)
);
alter table public.access enable row level security;
create policy "read own access" on public.access for select to authenticated
  using (lower(email) = lower(auth.jwt() ->> 'email'));

create or replace function public.can_see(cid text) returns boolean
language sql stable security definer set search_path = public as $$
  select not exists (select 1 from public.access a where lower(a.email) = lower(auth.jwt() ->> 'email'))
      or exists     (select 1 from public.access a where lower(a.email) = lower(auth.jwt() ->> 'email') and a.company_id = cid)
$$;
create or replace function public.unrestricted() returns boolean
language sql stable security definer set search_path = public as $$
  select not exists (select 1 from public.access a where lower(a.email) = lower(auth.jwt() ->> 'email'))
$$;
create or replace function public.is_editor() returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.members m where lower(m.email) = lower(auth.jwt() ->> 'email') and m.role = 'editor')
$$;

drop policy if exists "signed-in users can read" on public.books;
drop policy if exists "editors can add"    on public.books;
drop policy if exists "editors can update" on public.books;
drop policy if exists "editors can delete" on public.books;
create policy "see allowed companies" on public.books for select to authenticated using (public.can_see(id));
create policy "editors can add"       on public.books for insert to authenticated
  with check (public.is_editor() and public.unrestricted());
create policy "editors can update"    on public.books for update to authenticated
  using (public.is_editor() and public.can_see(id)) with check (public.is_editor() and public.can_see(id));
create policy "editors can delete"    on public.books for delete to authenticated
  using (public.is_editor() and public.can_see(id));

drop policy if exists "everyone signed in can read history" on public.audit;
create policy "read allowed history" on public.audit for select to authenticated
  using (company is null or public.can_see(company));

-- 2) Storage for attachments (receipts, photos, PDFs). Files are private.
insert into storage.buckets (id, name, public) values ('attachments', 'attachments', false)
  on conflict (id) do nothing;
create policy "read allowed attachments" on storage.objects for select to authenticated
  using (bucket_id = 'attachments' and public.can_see(split_part(name, '/', 1)));
create policy "editors add attachments" on storage.objects for insert to authenticated
  with check (bucket_id = 'attachments' and public.is_editor() and public.can_see(split_part(name, '/', 1)));
create policy "editors remove attachments" on storage.objects for delete to authenticated
  using (bucket_id = 'attachments' and public.is_editor() and public.can_see(split_part(name, '/', 1)));
