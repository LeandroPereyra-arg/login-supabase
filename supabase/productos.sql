-- ABM de productos: ejecutar completo en Supabase > SQL Editor > New query.
-- Se puede ejecutar más de una vez sin romper nada.

-- 1. Tabla -------------------------------------------------------------------
create table if not exists public.productos (
  id uuid primary key default gen_random_uuid(),
  usuario_id uuid not null default auth.uid()
    references auth.users(id) on delete cascade,
  nombre text not null,
  descripcion text,
  precio numeric(12, 2) not null check (precio >= 0),
  stock integer not null default 0 check (stock >= 0),
  activo boolean not null default true,
  creado_en timestamptz not null default now()
);

alter table public.productos
  add column if not exists imagen_url text;

alter table public.productos
  add column if not exists imagen_ruta text;

alter table public.productos enable row level security;

grant select, insert, update, delete
on table public.productos
to authenticated;

-- 2. Políticas RLS de la tabla ------------------------------------------------
drop policy if exists "Usuarios leen sus productos" on public.productos;
create policy "Usuarios leen sus productos"
on public.productos
for select
to authenticated
using ((select auth.uid()) = usuario_id);

drop policy if exists "Usuarios crean sus productos" on public.productos;
create policy "Usuarios crean sus productos"
on public.productos
for insert
to authenticated
with check ((select auth.uid()) = usuario_id);

drop policy if exists "Usuarios modifican sus productos" on public.productos;
create policy "Usuarios modifican sus productos"
on public.productos
for update
to authenticated
using ((select auth.uid()) = usuario_id)
with check ((select auth.uid()) = usuario_id);

drop policy if exists "Usuarios eliminan sus productos" on public.productos;
create policy "Usuarios eliminan sus productos"
on public.productos
for delete
to authenticated
using ((select auth.uid()) = usuario_id);

-- 3. Bucket de imágenes (público, hasta 5 MB) ----------------------------------
insert into storage.buckets (
  id,
  name,
  public,
  file_size_limit,
  allowed_mime_types
)
values (
  'productos',
  'productos',
  true,
  5242880,
  array['image/jpeg', 'image/png', 'image/webp']
)
on conflict (id) do update
set public = true,
    file_size_limit = 5242880,
    allowed_mime_types = array['image/jpeg', 'image/png', 'image/webp'];

-- 4. Políticas de Storage ------------------------------------------------------
drop policy if exists "Usuarios suben imagenes de productos" on storage.objects;
create policy "Usuarios suben imagenes de productos"
on storage.objects
for insert
to authenticated
with check (
  bucket_id = 'productos'
  and (storage.foldername(name))[1] = auth.uid()::text
);

drop policy if exists "Usuarios ven sus imagenes de productos" on storage.objects;
create policy "Usuarios ven sus imagenes de productos"
on storage.objects
for select
to authenticated
using (
  bucket_id = 'productos'
  and owner_id = auth.uid()::text
);

drop policy if exists "Usuarios eliminan sus imagenes de productos" on storage.objects;
create policy "Usuarios eliminan sus imagenes de productos"
on storage.objects
for delete
to authenticated
using (
  bucket_id = 'productos'
  and owner_id = auth.uid()::text
);
