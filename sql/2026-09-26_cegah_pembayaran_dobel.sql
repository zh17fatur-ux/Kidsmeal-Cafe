-- Kidsmeal Cafe — tolak pembayaran kembar karena tombol tertekan dua kali (2026-09-26)
--
-- Ditemukan beberapa pembayaran tercatat dua kali dalam hitungan detik (siswa, nominal,
-- tanggal & metode sama). Database menolak catatan identik dari akun yang sama dalam
-- 60 detik. Pembayaran berulang yang memang disengaja cukup dicatat setelah 1 menit.

begin;

create or replace function public.prevent_duplicate_payment()
returns trigger
language plpgsql
set search_path to 'public'
as $function$
begin
  -- kunci per siswa agar dua permintaan bersamaan tidak lolos berbarengan
  perform pg_advisory_xact_lock(hashtext('payment:' || new.student_id::text));
  if exists (
    select 1 from public.payments p
    where p.student_id = new.student_id
      and p.amount = new.amount
      and p.payment_date = new.payment_date
      and p.method = new.method
      and p.created_by = new.created_by
      and p.created_at > now() - interval '60 seconds'
  ) then
    raise exception 'Pembayaran yang sama baru saja tercatat. Muat ulang halaman untuk melihatnya; bila memang pembayaran kedua, simpan lagi setelah 1 menit.';
  end if;
  return new;
end;
$function$;

drop trigger if exists trg_prevent_duplicate_payment on public.payments;
create trigger trg_prevent_duplicate_payment before insert on public.payments
  for each row execute function public.prevent_duplicate_payment();

revoke execute on function public.prevent_duplicate_payment() from public, anon;
grant execute on function public.prevent_duplicate_payment() to authenticated;

commit;
