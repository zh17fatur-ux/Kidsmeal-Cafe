# Kidsmeal Cafe Online

Versi ini sudah terhubung langsung ke database Supabase project Anda.

## Yang sudah online
- Login / sign up menggunakan Supabase Auth
- Data siswa dan menu tersimpan di PostgreSQL Supabase
- Pesanan multi-menu
- Tagihan dan deposit dihitung dari transaksi online
- Pembayaran online
- Rekap mingguan
- Request pembatalan + alasan
- Persetujuan pembatalan oleh role Approver
- Audit trail berdasarkan akun login

## Menjalankan
Cara paling mudah untuk tes:
1. Extract ZIP.
2. Jalankan file `index.html` dari web server sederhana atau upload ke static hosting.
3. Buat akun Admin dari layar "Buat Akun".
4. Jika Supabase meminta verifikasi email, selesaikan verifikasi lalu login.

Untuk development lokal, VS Code Live Server cocok digunakan.

## Role Approver
Akun baru otomatis ber-role `admin`.
Buat akun kedua untuk supervisor/approver. Setelah akun tersebut tercipta, role-nya perlu diubah menjadi `approver` di database.
Karena perubahan role adalah tindakan keamanan, aplikasi frontend tidak diberi hak untuk mengubah role sendiri.

## Catatan keamanan
Frontend hanya berisi Supabase publishable key, bukan secret/service-role key.
Akses data dijaga dengan Row Level Security (RLS) dan validasi pembatalan juga ditegakkan di database.

## Supabase JS
Frontend menggunakan @supabase/supabase-js 2.112.4 dari CDN.

## Perubahan v2
- Data Siswa: filter Aktif/Nonaktif, edit, nonaktifkan, aktifkan kembali.
- Data Menu: filter Aktif/Nonaktif, edit nama/kategori/harga, nonaktifkan, aktifkan kembali.
- Menu nonaktif tidak muncul pada input pesanan.
- Siswa nonaktif tidak muncul untuk pesanan baru, tetapi histori dan saldo lama tetap tersedia.
- Manajemen User hanya tampil untuk Approver.
- Approver dapat mengubah role akun lain antara Admin dan Approver.
- Database menolak Admin mengubah role dan menolak Approver mengubah role dirinya sendiri.

- Role management diperketat dengan RLS dan izin UPDATE hanya pada kolom `role`; Admin tidak bisa mengubah role, dan Approver tidak bisa mengubah role dirinya sendiri.

## Perubahan v3
- Hanya role Admin yang dapat mengajukan pembatalan pesanan.
- Role Approver tidak dapat mengajukan pembatalan.
- Approver hanya dapat menyetujui atau menolak permintaan pembatalan dari Admin.
- Aturan ini ditegakkan di frontend dan database Supabase.

## Perubahan v4
- Ditambahkan dashboard khusus Kasir Kidsmeal.
- Kasir Kidsmeal fokus pada Input Pesanan dan Rekap Pesanan Hari Ini.
- Rekap hari ini menampilkan jam order dibuat.
- Status operasional: Sementara Dibuat dan Selesai.
- Status pembatalan tetap terpisah dan membutuhkan approval.
- Admin dapat menandai pesanan selesai atau mengembalikannya ke Sementara Dibuat.
- Admin dapat mengajukan pembatalan dari Rekap Pesanan Hari Ini.
- Approver tetap hanya menyetujui/menolak pembatalan.

## Perubahan v5
- Memperbaiki navigasi agar Kasir Kidsmeal dan Rekap Pesanan Hari Ini tampil untuk Admin dan Approver.
- Kedua menu tersebut tidak lagi bergantung pada role.
- Role tetap membatasi aksi sensitif: Admin mengajukan pembatalan, Approver menyetujui/menolak.

## Perubahan v6
- Menu Kasir Kidsmeal dihapus karena fungsinya sama dengan Input Pesanan.
- Input Pesanan tetap menjadi satu-satunya halaman untuk membuat order.
- Pesanan baru berstatus Sementara Dibuat.
- Pesanan Sementara Dibuat belum masuk Rekap Mingguan dan belum menjadi tagihan siswa.
- Admin mengubah status menjadi Selesai dari Rekap Pesanan Hari Ini.
- Setelah Selesai, pesanan otomatis masuk Rekap Mingguan dan perhitungan tagihan.
- Jika status dikembalikan ke Sementara Dibuat, pesanan sementara keluar dari rekap mingguan dan tagihan.
- Pembatalan tetap membutuhkan approval dan setelah disetujui tidak dihitung sebagai tagihan.

## Perubahan v7
- Role Admin hanya melihat Dashboard, Input Pesanan, dan Rekap Pesanan Hari Ini.
- Role Approver melihat seluruh menu.
- Di Rekap Pesanan Hari Ini, Admin mengubah status lewat dropdown langsung.
- Dropdown status hanya berisi Sementara Dibuat dan Selesai.
- Sementara Dibuat belum menjadi tagihan dan belum masuk Rekap Mingguan.
- Selesai otomatis menjadi tagihan dan masuk Rekap Mingguan.
- Menunggu Approval / Dibatalkan tidak dapat diubah melalui dropdown.

## Perubahan v8
- Urutan menu Admin menjadi: Dashboard → Rekap Pesanan Hari Ini → Input Pesanan.
- Rekap Pesanan Hari Ini diurutkan dari pesanan paling awal masuk ke paling akhir.

## Perubahan v9
- Urutan menu Admin diperbaiki menjadi: Dashboard → Input Pesanan → Rekap Pesanan Hari Ini.
- Urutan rekap harian tetap dari pesanan paling awal ke paling akhir.

## Perubahan v10
- Status pada Dashboard sekarang mengikuti status operasional pesanan.
- Status yang tampil: Sementara Dibuat, Selesai, Menunggu Approval, Dibatalkan.
- Dashboard memberi keterangan bahwa Sementara Dibuat belum menjadi tagihan, sedangkan Selesai sudah menjadi tagihan dan masuk Rekap Mingguan.

## Perubahan v11 Mobile
- Navigasi di HP berubah menjadi bottom navigation.
- Dashboard dan form lebih responsif untuk layar kecil.
- Tombol dan input diperbesar agar nyaman disentuh.
- Rekap Pesanan Hari Ini memakai tampilan kartu khusus di HP.
- Tabel besar tetap bisa di-scroll horizontal.
- Modal pembatalan tampil seperti bottom sheet di HP.

## Perubahan v12
- Menu Pembayaran sekarang tampil untuk role Admin.
- Urutan fungsi Admin: Dashboard, Input Pesanan, Rekap Pesanan Hari Ini, Pembayaran.
- Approver tetap melihat seluruh menu.
- Database operasional telah dikosongkan agar siap diisi data real.
- Akun login dan role tetap dipertahankan.

## Perubahan v13
- Menu Pembayaran Admin memakai dropdown Pilih Siswa.
- Pencarian nama/kelas memfilter isi dropdown.
- Saat siswa dipilih, total tagihan, pembayaran, sisa saldo/deposit langsung tampil.
- Jika belum ada data siswa, aplikasi menampilkan pesan yang jelas.

## Perubahan v14
- Pemilihan siswa di menu Pembayaran sekarang sama seperti Input Pesanan.
- Ketik nama/kelas lalu langsung tap siswa dari daftar hasil.
- Tidak perlu dropdown kedua.
- Setelah siswa dipilih, tagihan langsung tampil.

## Perubahan v15 — Master Account
- Master Account adalah satu-satunya akun yang dapat mengubah role user.
- Master dapat Nonaktifkan / Aktifkan kembali user.
- Nonaktifkan user memblokir akses dan menghapus sesi aktif.
- Hapus Permanen hanya untuk user tanpa histori transaksi.
- User dengan histori tidak bisa dihapus permanen; gunakan Nonaktifkan.
- Master Account tidak dapat dinonaktifkan, dihapus, atau diturunkan dari Approver.
- Approver biasa dapat melihat Manajemen User tetapi tidak dapat mengubah user.
