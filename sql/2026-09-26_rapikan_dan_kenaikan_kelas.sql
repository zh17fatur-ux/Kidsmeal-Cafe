-- Kidsmeal Cafe — perapian database & kenaikan kelas dengan verifikasi (2026-09-26)
--
-- A. Perapian teknis (hak akses, index, policy, updated_at otomatis)
-- B. Penyeragaman nama siswa, kelas & menu — otomatis untuk data baru juga
-- C. Kenaikan kelas 1 Juli:
--      otomatis       : SD 1A..5C → kelas berikutnya (huruf tetap), PG → TK A, SMP 7 → 8, SMP 8 → 9
--      perlu verifikasi: TK A → TK B1/B2/B3, TK B → Lulus TK, kelas 6 → Lulus SD, SMP 9 → Lulus SMP

begin;

-- ===================================================================== A. Teknis

-- Fungsi tidak perlu bisa dipanggil pengunjung yang belum login
-- (dijalankan lagi di akhir berkas untuk fungsi yang dibuat di bawah)
alter default privileges in schema public revoke execute on functions from public, anon;

-- View saldo hanya untuk dibaca
revoke insert, update, delete on public.student_balances from authenticated;

-- Index untuk kolom relasi
create index if not exists idx_orders_created_by          on public.orders (created_by);
create index if not exists idx_orders_cancel_requested_by on public.orders (cancel_requested_by);
create index if not exists idx_orders_cancel_decided_by   on public.orders (cancel_decided_by);
create index if not exists idx_order_items_menu           on public.order_items (menu_id);
create index if not exists idx_payments_created_by        on public.payments (created_by);

-- auth.uid() dibungkus (select …) agar dihitung sekali per query, bukan per baris
alter policy orders_insert_admin on public.orders
  with check (public."current_role"() = any (array['admin','approver']::app_role[]) and created_by = (select auth.uid()));
alter policy payments_insert_admin on public.payments
  with check (public."current_role"() = any (array['admin','approver']::app_role[]) and created_by = (select auth.uid()));
alter policy profiles_read_staff on public.profiles
  using (id = (select auth.uid()) or public."current_role"() is not null);
alter policy profiles_role_update_approver on public.profiles
  using (public."current_role"() = 'approver' and id <> (select auth.uid()))
  with check (public."current_role"() = 'approver' and id <> (select auth.uid()));

-- ===================================================================== B. Penyeragaman

-- Nama kelas baku: PG, TK A, TK B1.., 1A..6C, SMP 7..9, Lulus TK/SD/SMP
create or replace function public.normalize_class_name(p text)
returns text
language plpgsql
immutable
set search_path to 'public'
as $function$
declare v text := upper(regexp_replace(btrim(coalesce(p, '')), '[[:space:]]+', ' ', 'g'));
begin
  if v in ('PG', 'PLAYGROUP')            then return 'PG'; end if;
  if v ~ '^TK ?A$'                       then return 'TK A'; end if;
  if v ~ '^TK ?B ?[1-9]$'                then return 'TK B' || right(v, 1); end if;
  if v ~ '^TK ?B$'                       then return 'TK B'; end if;
  if v ~ '^[1-6] ?[A-Z]$'                then return replace(v, ' ', ''); end if;
  if v ~ '^SMP ?[7-9]$'                  then return 'SMP ' || right(v, 1); end if;
  if v ~ '^LULUS (TK|SD|SMP)$'           then return 'Lulus ' || split_part(v, ' ', 2); end if;
  return btrim(regexp_replace(coalesce(p, ''), '[[:space:]]+', ' ', 'g'));
end;
$function$;

-- Nama: spasi dirapikan; bila ditulis huruf kecil semua / kapital semua → Huruf Awal Kapital
create or replace function public.normalize_person_name(p text)
returns text
language sql
immutable
set search_path to 'public'
as $function$
  select case when v = lower(v) or v = upper(v) then initcap(v) else v end
  from (select btrim(regexp_replace(coalesce(p, ''), '[[:space:]]+', ' ', 'g')) v) x;
$function$;

create or replace function public.students_before_write()
returns trigger
language plpgsql
set search_path to 'public'
as $function$
begin
  new.name := public.normalize_person_name(new.name);
  new.class_name := public.normalize_class_name(new.class_name);
  if tg_op = 'UPDATE' then new.updated_at := now(); end if;
  return new;
end;
$function$;

create or replace function public.menus_before_write()
returns trigger
language plpgsql
set search_path to 'public'
as $function$
begin
  new.name := public.normalize_person_name(new.name);
  new.category := btrim(new.category);
  if tg_op = 'UPDATE' then new.updated_at := now(); end if;
  return new;
end;
$function$;

drop trigger if exists trg_students_before_write on public.students;
create trigger trg_students_before_write before insert or update on public.students
  for each row execute function public.students_before_write();
drop trigger if exists trg_menus_before_write on public.menus;
create trigger trg_menus_before_write before insert or update on public.menus
  for each row execute function public.menus_before_write();

-- Rapikan data yang sudah ada (trigger di atas menyeragamkan)
update public.students set name = name, class_name = class_name
  where name <> public.normalize_person_name(name) or class_name <> public.normalize_class_name(class_name);

-- Salah ketik nama menu; nama di riwayat pesanan ikut disamakan
create temporary table menu_rename (old_name text, new_name text) on commit drop;
insert into menu_rename values
  ('rice bowl ay crispy sambal mata', 'Rice Bowl Ayam Crispy Sambal Matah'),
  ('rice bowl ay Moza',               'Rice Bowl Ayam Mozza'),
  ('Rice bowl Ayam Teryaki',          'Rice Bowl Ayam Teriyaki'),
  ('rice bowl chiken pop',            'Rice Bowl Chicken Pop'),
  ('Spaghety',                        'Spaghetti');
update public.menus m set name = r.new_name from menu_rename r where m.name = r.old_name;
update public.menus set name = name where name <> public.normalize_person_name(name);
update public.order_items i set menu_name = m.name
  from public.menus m
  where i.menu_id = m.id and i.menu_name <> m.name
    and (lower(i.menu_name) = lower(m.name)
         or exists (select 1 from menu_rename r where r.old_name = i.menu_name and r.new_name = m.name));

-- ===================================================================== C. Kenaikan kelas

alter table public.students
  add column if not exists promotion_pending text,
  add column if not exists promotion_pending_year integer;
comment on column public.students.promotion_pending is
  'Tujuan kenaikan/kelulusan yang menunggu verifikasi admin (mis. TK B, Lulus SD)';

-- Kolom hasil berubah (graduated_count → pending_count), jadi fungsi dibuat ulang
drop function if exists public.promote_students_for_new_school_year(integer);
create function public.promote_students_for_new_school_year(
  p_year integer default (extract(year from current_date))::integer)
returns table(updated_count integer, pending_count integer)
language plpgsql
set search_path to 'public'
as $function$
declare
  v_updated integer := 0;
  v_pending integer := 0;
begin
  -- Otomatis: SD 1–5, PG, SMP 7–8
  with promoted as (
    update public.students s
    set class_name = case
          when s.class_name ~ '^[1-5][A-Z]$' then (left(s.class_name, 1)::int + 1)::text || right(s.class_name, 1)
          when s.class_name = 'PG'     then 'TK A'
          when s.class_name = 'SMP 7'  then 'SMP 8'
          when s.class_name = 'SMP 8'  then 'SMP 9'
        end,
        last_promoted_year = p_year
    where s.active and coalesce(s.last_promoted_year, 0) < p_year
      and (s.class_name ~ '^[1-5][A-Z]$' or s.class_name in ('PG', 'SMP 7', 'SMP 8'))
    returning 1
  )
  select count(*) into v_updated from promoted;

  -- Perlu verifikasi admin: kelas tidak berubah sampai diverifikasi
  with pending as (
    update public.students s
    set promotion_pending = case
          when s.class_name = 'TK A'          then 'TK B'
          when s.class_name ~ '^TK B[1-9]?$'  then 'Lulus TK'
          when s.class_name ~ '^6[A-Z]$'      then 'Lulus SD'
          when s.class_name = 'SMP 9'         then 'Lulus SMP'
        end,
        promotion_pending_year = p_year,
        last_promoted_year = p_year
    where s.active and coalesce(s.last_promoted_year, 0) < p_year
      and (s.class_name = 'TK A' or s.class_name ~ '^TK B[1-9]?$' or s.class_name ~ '^6[A-Z]$' or s.class_name = 'SMP 9')
    returning 1
  )
  select count(*) into v_pending from pending;

  return query select v_updated, v_pending;
end;
$function$;

-- Verifikasi oleh admin/approver. p_approve=false → tetap di kelas sekarang.
create or replace function public.verify_student_promotion(p_student uuid, p_approve boolean, p_class text default null)
returns void
language plpgsql
security invoker
set search_path to 'public'
as $function$
declare
  v_target text;
  v_class text := public.normalize_class_name(p_class);
begin
  if public."current_role"() is null then
    raise exception 'Akun tidak aktif.';
  end if;
  select promotion_pending into v_target from public.students where id = p_student for update;
  if v_target is null then
    raise exception 'Siswa ini tidak sedang menunggu verifikasi kenaikan kelas.';
  end if;

  if not p_approve then
    update public.students set promotion_pending = null, promotion_pending_year = null where id = p_student;
  elsif v_target like 'Lulus %' then
    update public.students
      set active = false, class_name = v_target, promotion_pending = null, promotion_pending_year = null
      where id = p_student;
  elsif v_target = 'TK B' then
    if v_class !~ '^TK B[1-9]$' then
      raise exception 'Pilih kelas TK B (mis. TK B1, TK B2, TK B3).';
    end if;
    update public.students
      set class_name = v_class, promotion_pending = null, promotion_pending_year = null
      where id = p_student;
  else
    update public.students
      set class_name = v_target, promotion_pending = null, promotion_pending_year = null
      where id = p_student;
  end if;
  if not found then
    raise exception 'Data siswa tidak dapat diubah.';
  end if;
end;
$function$;
-- ===================================================================== Hak eksekusi fungsi
-- Pengguna login: boleh (policy, trigger & aplikasi memanggilnya). Pengunjung: tidak.
do $$
declare f record;
begin
  for f in select p.oid::regprocedure sig from pg_proc p where p.pronamespace = 'public'::regnamespace loop
    execute format('revoke execute on function %s from public, anon', f.sig);
    execute format('grant execute on function %s to authenticated', f.sig);
  end loop;
end $$;
-- Kenaikan kelas hanya dijalankan jadwal otomatis (cron)
revoke execute on function public.promote_students_for_new_school_year(integer) from authenticated;

commit;
