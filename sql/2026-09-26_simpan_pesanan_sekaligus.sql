-- Kidsmeal Cafe — simpan pesanan dan itemnya dalam satu transaksi (2026-09-26)
--
-- Sebelumnya aplikasi menyimpan kepala pesanan lalu item secara terpisah; bila langkah
-- kedua gagal (mis. koneksi putus) tertinggal pesanan tanpa item.
-- Fungsi ini menyimpan keduanya sekaligus: gagal satu, batal semua.
-- SECURITY INVOKER: policy RLS & trigger pesanan tetap berlaku seperti insert biasa.
-- Nama & harga menu diambil dari tabel menus saat disimpan.

begin;

create or replace function public.create_order_with_items(
  p_student_id uuid,
  p_order_date date,
  p_is_breakfast boolean,
  p_order_note text,
  p_items jsonb  -- [{"menu_id": "...", "qty": 2}, ...]
)
returns uuid
language plpgsql
security invoker
set search_path to 'public'
as $function$
declare
  v_id uuid;
  v_n integer;
begin
  if coalesce(jsonb_array_length(p_items), 0) = 0 then
    raise exception 'Pilih menu.';
  end if;

  insert into public.orders (student_id, order_date, status, progress_status, is_breakfast, order_note, created_by)
  values (p_student_id, p_order_date, 'active', 'preparing', coalesce(p_is_breakfast, false),
          nullif(trim(p_order_note), ''), auth.uid())
  returning id into v_id;

  insert into public.order_items (order_id, menu_id, menu_name, unit_price, qty)
  select v_id, m.id, m.name, m.price, (x->>'qty')::integer
  from jsonb_array_elements(p_items) x
  join public.menus m on m.id = (x->>'menu_id')::uuid;

  get diagnostics v_n = row_count;
  if v_n <> jsonb_array_length(p_items) then
    raise exception 'Ada menu yang tidak ditemukan. Muat ulang halaman lalu coba lagi.';
  end if;

  return v_id;
end;
$function$;

revoke execute on function public.create_order_with_items(uuid, date, boolean, text, jsonb) from public, anon;
grant execute on function public.create_order_with_items(uuid, date, boolean, text, jsonb) to authenticated;

commit;
