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

## Perubahan v16
- Memperbaiki bug Master Account tidak terbaca di frontend.
- Query profile sekarang mengambil is_master dan active.
- Dropdown ubah role serta tombol manajemen user akan tampil untuk Master.

## Perubahan v17
- Siswa yang dipilih di Input Pesanan kini tampil lebih tegas.
- Baris siswa terpilih memiliki border tebal, background jelas, nama lebih bold, dan badge "Dipilih".
- Ringkasan siswa terpilih juga dibuat lebih bold.
- Tampilan siswa terpilih di Pembayaran menggunakan gaya yang sama.

## Perubahan v18
- Admin mobile sekarang dapat mengubah status pesanan langsung dari kartu Rekap Pesanan Hari Ini.
- Pilihan status: Sementara Dibuat / Selesai.
- Kontrol status dinonaktifkan bila pesanan Menunggu Approval Batal atau sudah Dibatalkan.
- Setelah status diubah, data dimuat ulang agar tagihan dan rekap mengikuti status terbaru.

## Perubahan v19
- Kontrol status mobile diganti dari dropdown menjadi dua tombol besar: Sementara Dibuat dan Selesai.
- Tombol aktif dibuat lebih tegas untuk layar HP.
- Update status memverifikasi row hasil update dan menampilkan pesan bila ditolak.
- Pesanan active maupun cancel_rejected dapat diubah status; cancel_pending/cancelled tetap terkunci.

## Perubahan v20
- Admin dan Approver sama-sama dapat mengubah status pesanan.
- Berlaku di tampilan mobile dan desktop.
- Status yang dapat dipilih: Sementara Dibuat / Selesai.
- Pesanan Menunggu Approval Batal atau Dibatalkan tetap terkunci.
- Alur pembatalan tidak berubah: Admin mengajukan, Approver menyetujui/menolak.

## Perubahan v21
- Tampilan Pembayaran di mobile disesuaikan penuh untuk layar kecil.
- Riwayat pembayaran mobile memakai kartu, bukan tabel horizontal.
- Ringkasan siswa terpilih pada Pembayaran dibuat lebih tegas.
- Tombol Simpan Pembayaran dibuat penuh/lebar di mobile.
- Pada Input Pesanan, menu yang sudah dipilih diberi background, border, bold, dan badge "Dipilih × jumlah".
- Klik nama/kartu menu juga menambahkan menu, tidak hanya tombol plus.
- Highlight menu selalu mengikuti perubahan quantity di keranjang.

## Perubahan v22 — Pesanan Sarapan
- Input Pesanan memiliki checkbox "Apakah pesanan untuk sarapan?".
- Pesanan sarapan disimpan di orders.is_breakfast.
- Rekap Pesanan Hari Ini memiliki blok khusus "Pesanan Sarapan" di bagian atas.
- Pesanan sarapan diberi badge 🌅 SARAPAN dan dihitung terpisah.
- Pesanan biasa tetap muncul di bagian "Pesanan Lainnya".
- Berlaku di desktop dan mobile.
- Admin dan Approver dapat mengubah status Sementara Dibuat / Selesai.
- Workflow pembatalan tetap sama.

## Perubahan v23
- Klik nama/kartu menu hanya memilih menu satu kali.
- Klik berulang pada menu yang sama tidak lagi menambah quantity.
- Tombol menu berubah menjadi tanda centang setelah dipilih.
- Quantity 2 atau lebih hanya dapat diatur lewat tombol + / - di keranjang sebelum Simpan Pesanan.
- Badge menu menampilkan "Dipilih" tanpa quantity agar tidak membingungkan.

## Perubahan v24
- Memperbaiki handler lama yang masih menambah qty setiap kali menu diklik.
- Klik kartu/nama/tombol menu sekarang hanya memilih qty 1.
- Klik berulang tidak mengubah quantity.
- Tombol menu berubah menjadi tanda centang setelah dipilih.
- Penambahan qty hanya melalui tombol + pada keranjang sebelum Simpan Pesanan.

## Perubahan v25
- Status Selesai memakai hijau soft, Sementara Dibuat memakai kuning soft.
- Approver/Master dapat mengisi pembayaran langsung dari menu Tagihan.
- Form pembayaran Tagihan mendukung Tunai dan Transfer, tanggal, nominal, dan catatan.
- Manajemen User hanya terlihat untuk Master Account.
- Rekap Mingguan memiliki baris TOTAL PER HARI dan total keseluruhan minggu.

## Perubahan v26 — Tagihan Per Minggu
- Menu Tagihan memiliki pilihan pekan berdasarkan tanggal.
- Periode otomatis dihitung Senin–Minggu.
- Saldo Awal membawa hutang atau deposit dari pekan-pekan sebelumnya.
- Pesanan Pekan Ini hanya menghitung pesanan berstatus Selesai dalam periode terpilih.
- Pembayaran Pekan Ini hanya menghitung pembayaran dalam periode terpilih.
- Saldo Akhir = Saldo Awal + Pesanan Pekan Ini - Pembayaran Pekan Ini.
- Deposit minggu sebelumnya otomatis menutup tagihan pada minggu berikutnya.
- Approver/Master tetap dapat mengisi pembayaran langsung dari Tagihan.

## Perubahan v27 — Tagihan Mingguan Tanpa Carry Hutang
- Tagihan hanya tampil pada pekan saat pesanan terjadi.
- Hutang/tagihan pekan sebelumnya tidak dibawa ke pekan berikutnya.
- Hanya deposit yang dibawa ke pekan-pekan berikutnya sampai terpakai.
- Deposit Awal otomatis mengurangi pesanan pada pekan terpilih.
- Jika deposit masih tersisa, siswa tetap muncul pada pekan berikutnya sebagai Deposit Aktif.
- Jika tidak ada pesanan, pembayaran, atau deposit aktif pada suatu pekan, siswa tidak ditampilkan.

## Perubahan v28 — PWA Installable
- Kidsmeal Cafe sekarang mendukung Progressive Web App (PWA).
- Android/Chrome dapat menampilkan tombol Install App / Add to Home Screen.
- Setelah di-install, aplikasi terbuka dalam mode standalone seperti aplikasi biasa.
- Ikon aplikasi 192px dan 512px disertakan.
- Service worker menggunakan network-first untuk halaman utama agar update GitHub → Vercel cepat masuk.
- Data Supabase/API tetap menggunakan jaringan dan tidak dicache sebagai data offline.
- File baru yang WAJIB ikut di-upload ke GitHub: manifest.webmanifest, sw.js, icon-192.png, icon-512.png.
