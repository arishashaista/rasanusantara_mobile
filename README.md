# Proyek Akhir Semester C08 - PBP Gasal 2024/2025
- [Nama Aplikasi](#nama-aplikasi-rasa-nusantara)
- [Profil Kelompok](#anggota-kelompok)
- [Tautan Aplikasi](#url-deployment)
- [Tautan Desain Aplikasi](#desain-aplikasi)
- [Video Promosi](#video-promosi)
- [Deskripsi Aplikasi](#deskripsi-aplikasi)
- [Modul Aplikasi](#modul-aplikasi)
- [Peran Pengguna](#peran-pengguna)
- [Alur Pengintegrasian](#alur-pengintegrasian)

# Nama Aplikasi: Rasa Nusantara

## Anggota Kelompok
| Nama | NPM |
| :--------------: | :--------: |
| Refalino Shahzada Ghassani | 2306152203 |
| Arisha Shaista Aurelya | 2306152140 |
| Muhammad Dzikri Ilmansyah | 2306275544 |
| Fikar Hilmi Adhrevi | 2306203873|
| Muhammad Rayyan Wiradana | 2306275342 |

## URL Deployment
🔗 Tautan Aplikasi: [Aplikasi Rasa Nusantara](https://install.appcenter.ms/orgs/rasa-nusantara/apps/rasa-nusantara/distribution_groups/public/releases/1)

## Desain Aplikasi
🔗 Tautan Desain: [Desain Aplikasi Rasa Nusantara](https://www.figma.com/design/RlIclSyvjBlbz1yGiJPcsl/TK-PAS-PBP?node-id=16-6&t=tWWgGXlHY2D7wcX5-1)

## Video Promosi
🔗 Tautan Video: [Video Promosi Aplikasi Rasa Nusantara](https://drive.google.com/file/d/1oLV9Bgg8F9bSY8smVie6DroJKhMEcwcd/view?usp=sharing)

## Deskripsi Aplikasi
**Rasa Nusantara** adalah aplikasi mobile inovatif yang dirancang untuk memudahkan pengguna dalam menemukan dan mengeksplorasi berbagai makanan tradisional Indonesia yang berlokasi di Yogyakarta. Melalui aplikasi mobile ini, pengguna dapat dengan mudah mengakses informasi lengkap mengenai restoran yang ada di Yogyakarta, termasuk menu, lokasi, harga, dan ulasan dari pengguna lain.

Tujuan utama dari **Rasa Nusantara** adalah untuk meningkatkan visibilitas dan popularitas kuliner lokal, mendukung pelestarian warisan budaya gastronomi Indonesia, serta memberikan dampak positif terhadap perekonomian lokal dengan mendorong peningkatan kunjungan ke restoran tradisional.

## Modul Aplikasi
1. Pengguna menambahkan restoran ke daftar favorit.
    - Dikerjakan oleh Arisha Shaista Aurelya
2. Filter daftar restoran berdasarkan harga tertinggi dan terendah serta filter daftar restoran berdasarkan beberapa kategori makanan.
    - Dikerjakan oleh Arisha Shaista Aurelya
3. Halaman utama, halaman details product, dan card product.
    - Dikerjakan oleh Arisha Shaista Aurelya
4. Pengguna menambahkan masukan atau saran terhadap restoran dan dapat menilai restoran tersebut.
    - Dikerjakan oleh Fikar Hilmi Adhrevi
6. Autentikasi dan halaman Login maupun Register
    - Dikerjakan oleh Fikar Hilmi Adhrevi
7. Halaman daftar restoran.
    - Dikerjakan oleh Fikar Hilmi Adhrevi
8. Pengguna dapat melakukan, memperbarui, dan menghapus reservasi ke restoran.
    - Dikerjakan oleh Muhammad Dzikri Ilmansyah
9. Admin dapat mengelola daftar restoran yang terdaftar di aplikasi, termasuk menambahkan, melihat, memperbarui, dan menghapus informasi restoran.
    - Dikerjakan oleh Refalino Shahzada Ghassani
10. Halaman admin.
    - Dikerjakan oleh Refalino Shahzada Ghassani
11. Admin dapat mengelola menu makanan yang ditawarkan, termasuk menambahkan, melihat, memperbarui, dan menghapus item menu.
    - Dikerjakan oleh Muhammad Rayyan Wiradana

## Peran Pengguna
- **Member**
    - Melihat semua daftar restoran dan makanan.
    - Memberikan rating dan ulasan untuk restoran.
    - Menambahkan restoran ke daftar favorit mereka.
    - Membuat reservasi untuk restoran.
- **Admin**
    - Menambahkan dan mengelola daftar restoran serta menu makanan.
- **Guest**
    - Dapat melihat semua daftar restoran.
    - Tidak dapat memberikan rating atau ulasan.
    - Tidak dapat menambahkan restoran atau makanan ke daftar favorit.
    - Tidak dapat membuat reservasi.

## Alur Pengintegrasian

1. Menambahkan package/library seperti `http` pada Flutter agar aplikasi dapat mengirim request HTTP ke server Django dan memastikan
REST API diimplementasikan menggunakan Django REST Framework (DRF) atau fungsi JSONResponse pada server Djano.
2. Mengimplementasikan autentikasi berbasis cookie dengan menggunakan library seperti `pbp_django_auth` di Flutter. Kemudian, menggunakan
mekanisme login, logout, dan registrasi dari server Django untuk otorisasi pengguna. Setelahnya, memastikan semua request ke server bersifat terautentikasi sesuai
peran pengguna.
3. Aplikasi Flutter akan mengirimkan request (GET, POST, atau lainnya) ke server Django untuk mengambil atau memodifikasi data.
4. Django menerima dan memproses request, termasuk validasi data dan autentikasi pengguna. Django berinteraksi dengan database menggunakan ORM (Object Relational Mapping)
untuk mengakses atau memodifikasi data.
5. Data yang diambil dari database diubah menjadi format JSON menggunakan Django Serializers atau fungsi bawaan seperti JsonResponse.
Kemudian, Server Django mengirimkan response dalam format JSON yang sudah terstruktur dan response ini mencakup keseluruhan data yang diminta seperti
daftar produk, atau detail produk.
6. Aplikasi Flutter menerima response JSON dan data yang telah di-parse disimpan dalam model atau state management Provider di Flutter.
7. Desain UI pada Flutter yang dirancang berdasarkan desain situs web yang ada untuk konsistensi dan data produk yang diterima
ditampilkan dalam interface user menggunakan widget seperti ListView, GridView, atau lainnya.
8. Mengintegrasikan Flutter dengan server Django menggunakan konsep asynchronous HTTP melalui Future dan async/await dan 
melakukan testing untuk memastikan data yang dikirimkan dan diterima sesuai dengan spesifikasi API.

-