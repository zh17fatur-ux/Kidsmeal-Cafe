-- Kidsmeal Cafe — akun baru wajib diaktifkan Master Account (2026-09-26)
--
-- Masalah: siapa pun yang mendaftar lewat "Buat Akun" otomatis menjadi Admin aktif
-- dan bisa membaca/mengubah semua data siswa, pesanan, dan pembayaran.
--
-- Perbaikan:
--   1. Akun baru dibuat NONAKTIF (role tetap admin sebagai bawaan).
--   2. current_role() hanya mengembalikan role untuk akun yang AKTIF,
--      sehingga semua policy tulis otomatis menolak akun nonaktif.
--   3. Policy baca (yang sebelumnya "true" untuk semua akun login) kini
--      mensyaratkan akun aktif. Akun nonaktif hanya bisa membaca profilnya sendiri.
--   4. Role anon (belum login) dicabut aksesnya ke tabel & view Kidsmeal.
--   5. Hak TRUNCATE/TRIGGER/REFERENCES dicabut dari akun login (tidak dipakai aplikasi).
--
-- Akun yang sudah ada tidak berubah (semuanya aktif). Master Account mengaktifkan
-- akun baru dari menu Manajemen User → "Aktifkan".

begin;

-- 1. Akun baru nonaktif
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path to 'public'
as $function$
begin
  insert into public.profiles (id, full_name, role, email, active)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'full_name', split_part(new.email,'@',1)),
    'admin',
    new.email,
    false
  )
  on conflict (id) do update set email = excluded.email;
  return new;
end;
$function$;

-- 2. Role hanya berlaku untuk akun aktif.
--    SECURITY DEFINER agar pembacaan profiles di sini tidak memicu policy profiles
--    (yang memanggil current_role() lagi → rekursi tanpa akhir).
create or replace function public."current_role"()
returns app_role
language sql
stable
security definer
set search_path to 'public'
as $function$
  select role from public.profiles where id = auth.uid() and active;
$function$;
revoke execute on function public."current_role"() from public, anon;
grant execute on function public."current_role"() to authenticated;

-- 3. Policy baca mensyaratkan akun aktif
alter policy menus_read       on public.menus       using (public."current_role"() is not null);
alter policy students_read    on public.students    using (public."current_role"() is not null);
alter policy orders_read      on public.orders      using (public."current_role"() is not null);
alter policy order_items_read on public.order_items using (public."current_role"() is not null);
alter policy payments_read    on public.payments    using (public."current_role"() is not null);
alter policy profiles_read_staff on public.profiles
  using (id = auth.uid() or public."current_role"() is not null);

-- 4. Pengunjung yang belum login tidak perlu akses apa pun
revoke all on public.menus, public.students, public.orders, public.order_items,
              public.payments, public.profiles, public.student_balances
  from anon;

-- 5. Hak yang tidak dipakai aplikasi
revoke truncate, trigger, references
  on public.menus, public.students, public.orders, public.order_items,
     public.payments, public.profiles, public.student_balances
  from authenticated;

commit;
