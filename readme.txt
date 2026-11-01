EASY BOOKS - put it on the internet as a normal website
========================================================

This folder IS the website: index.html (the app), config.js (settings), setup.sql (database).
It does not depend on Claude. It needs a place to be hosted (free options below).

OPTION A - one person, one device (5 minutes, no sign-up for a database)
1. Go to https://app.netlify.com/drop and sign in (free).
2. Drag this whole folder onto the page. Netlify gives you a web address.
3. Open it. Data is saved in that browser only. Use "Download backup" on the
   Dashboard regularly, because clearing browser data erases it.

OPTION B - several people and devices share the same books (about 20 minutes)
1. Create a free account at https://supabase.com and click "New project".
   Choose the region nearest you (Singapore). Save the database password.
2. In the project: SQL Editor -> New query -> paste everything from setup.sql -> Run.
3. Authentication -> Sign In / Providers (or Settings): turn OFF "Allow new users
   to sign up". Then Authentication -> Users -> Add user: create an email and
   password for each person who may use the books.
4. Project Settings -> API: copy the "Project URL" and the "anon public" key.
5. Open config.js in Notepad, paste them between the quote marks, and save.
6. Go to https://app.netlify.com/drop and drag this folder in (or drag it again
   onto your existing site to update it). Open the address and sign in.

Notes
- The anon key is meant to be public. The database rules in setup.sql mean only
  the users you add can read or write anything.
- If two people save at the same instant, the second save is refused and the
  latest data is loaded. Repeat that one entry. No one's data is silently lost.
- Other people see changes within about 15 seconds.
- Free Supabase projects can pause after a week of no use. Open the Supabase
  dashboard and click Restore if that happens.
- Your own web address: in Netlify, Domain management -> Add a custom domain.
- Keep copies: Dashboard -> Download backup saves a file of the current company.

UPGRADE 2 (roles, history, receipts, Bahasa Melayu)
- Existing installs: Supabase -> SQL Editor -> paste upgrade-2.sql -> Run. Then upload the new folder to Netlify.
- New installs: run setup.sql first, then upgrade-2.sql.
- Everyone who already had a login stays an EDITOR. New users you add are VIEW-ONLY until you list them as editors:
  Supabase -> Table Editor -> members -> Insert row -> email (lowercase) and role = editor.
  To make someone view-only again, change role to viewer (or delete their row).
- The "History" page shows who changed what and when.
- Language: use the English / Bahasa Melayu links under the sidebar.

UPGRADE 3 (multi-line invoices/bills, products, partial payments, credits, aging, invoice PDF, closing date)
- No new SQL is needed. Just upload the new folder to Netlify. Download a backup of every company first.
- Existing invoices and bills are converted automatically to one-line documents the first time they load.
- Settings page: company details for invoice PDFs, and "closed through" date (locks old periods).

UPGRADE 4 (PDF preview, new invoice layout, logo, payment details, safety copies)
- Before uploading: run backup-before-upgrade.sql in Supabase, and click Download backup in each company.
- No database change. Existing records are not rewritten; new settings are optional fields.
- To go back to the previous version instantly: Netlify -> Deploys -> click an older deploy -> Publish deploy.
- Settings page: upload a logo, enter Beneficiary name / Bank name / Bank account no. (printed on invoices).
