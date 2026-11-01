-- Run this in Supabase (SQL Editor -> New query -> paste -> Run) BEFORE you upload a new version.
-- It makes a full copy of all your companies' data inside your own database.
-- If you run it again later, change the name (for example ..._2) because a table with the same name cannot be created twice.
create table public.books_backup_before_upgrade as select * from public.books;
alter table public.books_backup_before_upgrade enable row level security;  -- keeps the copy private

-- To restore one company from the copy (only if ever needed; replace main with the company id):
-- update public.books b set data = c.data, version = b.version + 1
--   from public.books_backup_before_upgrade c where b.id = c.id and b.id = 'main';
