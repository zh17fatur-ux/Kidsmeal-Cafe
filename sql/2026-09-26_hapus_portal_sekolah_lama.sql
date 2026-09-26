-- Hapus sisa portal sekolah lama (ACG) dari database Kidsmeal (2026-09-26)
--
-- Datanya sudah dipindahkan ke portal sekolah-satu-pintu (impor 22 Sep 2026).
-- Backup lengkap sebelum penghapusan: Downloads\backup-portal-lama-2026-09-26
-- Tabel Kidsmeal (students, menus, orders, order_items, payments, profiles) TIDAK disentuh.

begin;

-- Jadwal SPP bulanan portal lama
select cron.unschedule(jobid) from cron.job where jobname = 'acg-monthly-spp';

-- View & fungsi portal lama
drop view if exists public.acg_charge_balances;
do $$
declare f record;
begin
  for f in
    select p.oid::regprocedure as sig
    from pg_proc p
    where p.pronamespace = 'public'::regnamespace and p.proname like 'acg\_%'
  loop
    execute format('drop function %s', f.sig);
  end loop;
end $$;

-- Tabel portal lama (public.acg_*)
do $$
declare t record;
begin
  for t in
    select c.relname
    from pg_class c
    where c.relnamespace = 'public'::regnamespace and c.relkind in ('r','p') and c.relname like 'acg\_%'
  loop
    execute format('drop table public.%I cascade', t.relname);
  end loop;
end $$;

-- Schema portal lama (semua tabelnya kosong)
drop schema if exists acg_portal cascade;
drop schema if exists acg_portal_migrations cascade;

commit;
