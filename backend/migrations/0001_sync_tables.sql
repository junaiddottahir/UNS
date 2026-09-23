-- Synced data for signed-in users only (architecture.md: storage model).
-- Holds settings and tasbih history. Never location, mood, journal or
-- voice data. Every row belongs to one user and is deleted with them.

create table public.user_settings (
  user_id uuid primary key references auth.users (id) on delete cascade,
  settings jsonb not null,
  updated_at timestamptz not null default now(),
  -- The server never stores location (invariant 5).
  constraint user_settings_no_location check (
    not (settings ?| array['location', 'lat', 'lng', 'latitude', 'longitude'])
  )
);

create table public.tasbih_days (
  user_id uuid not null references auth.users (id) on delete cascade,
  day date not null,
  count integer not null check (count >= 0),
  updated_at timestamptz not null default now(),
  primary key (user_id, day)
);

alter table public.user_settings enable row level security;
alter table public.tasbih_days enable row level security;

-- Each signed-in user reads and writes only their own rows.
create policy "own settings: select" on public.user_settings
  for select to authenticated using ((select auth.uid()) = user_id);
create policy "own settings: insert" on public.user_settings
  for insert to authenticated with check ((select auth.uid()) = user_id);
create policy "own settings: update" on public.user_settings
  for update to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);
create policy "own settings: delete" on public.user_settings
  for delete to authenticated using ((select auth.uid()) = user_id);

create policy "own tasbih: select" on public.tasbih_days
  for select to authenticated using ((select auth.uid()) = user_id);
create policy "own tasbih: insert" on public.tasbih_days
  for insert to authenticated with check ((select auth.uid()) = user_id);
create policy "own tasbih: update" on public.tasbih_days
  for update to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);
create policy "own tasbih: delete" on public.tasbih_days
  for delete to authenticated using ((select auth.uid()) = user_id);

-- In-app account deletion (App Store requirement): a signed-in user
-- deletes themselves; their rows go with them (on delete cascade).
create function public.delete_my_account()
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if auth.uid() is null then
    raise exception 'not signed in';
  end if;
  delete from auth.users where id = auth.uid();
end;
$$;

revoke all on function public.delete_my_account() from public, anon;
grant execute on function public.delete_my_account() to authenticated;
