import 'package:flutter_test/flutter_test.dart';
import 'package:project_kelompok/model/tiket_model.dart';
import 'package:project_kelompok/model/user_model.dart';
import 'package:project_kelompok/model/misi_model.dart';
import 'package:project_kelompok/model/berita_model.dart';
import 'package:project_kelompok/model/poin_model.dart';

void main() {
  group('Ticket Model', () {
    test('toMap() mengembalikan map yang benar', () {
      final ticket = Ticket(
        id: 1,
        hadiah: 'Voucher Belanja',
        poin: 50,
        tanggal: '2024-01-01',
      );

      final map = ticket.toMap();

      expect(map['id'], 1);
      expect(map['hadiah'], 'Voucher Belanja');
      expect(map['poin'], 50);
      expect(map['tanggal'], '2024-01-01');
    });

    test('fromMap() membuat object Ticket dengan benar', () {
      final map = {
        'id': 2,
        'hadiah': 'Voucher Makanan',
        'poin': 100,
        'tanggal': '2024-02-01',
      };

      final ticket = Ticket.fromMap(map);

      expect(ticket.id, 2);
      expect(ticket.hadiah, 'Voucher Makanan');
      expect(ticket.poin, 100);
      expect(ticket.tanggal, '2024-02-01');
    });

    test('fromMap() tetap bekerja tanpa id', () {
      final map = {
        'hadiah': 'Merchandise Evergreen',
        'poin': 200,
        'tanggal': '2024-03-01',
      };

      final ticket = Ticket.fromMap(map);

      expect(ticket.id, isNull);
      expect(ticket.hadiah, 'Merchandise Evergreen');
      expect(ticket.poin, 200);
      expect(ticket.tanggal, '2024-03-01');
    });

    test('toMap() dan fromMap() konsisten', () {
      final ticket = Ticket(
        id: 3,
        hadiah: 'Tiket Event',
        poin: 300,
        tanggal: '2024-04-01',
      );

      final map = ticket.toMap();
      final result = Ticket.fromMap(map);

      expect(result.id, ticket.id);
      expect(result.hadiah, ticket.hadiah);
      expect(result.poin, ticket.poin);
      expect(result.tanggal, ticket.tanggal);
    });
  });

  group('User Model', () {
    test('toMap() mengembalikan map yang benar', () {
      final user = User(
        id: 1,
        username: 'ferdinand',
        email: 'ferdinand@mail.com',
        password: '123456',
        profilePicture: 'profile.png',
      );

      final map = user.toMap();

      expect(map['id'], 1);
      expect(map['username'], 'ferdinand');
      expect(map['email'], 'ferdinand@mail.com');
      expect(map['password'], '123456');
      expect(map['profilePicture'], 'profile.png');
    });

    test('fromMap() membuat object User dengan benar', () {
      final map = {
        'id': 2,
        'username': 'louis',
        'email': 'louis@mail.com',
        'password': 'abcdef',
        'profilePicture': 'avatar.jpg',
      };

      final user = User.fromMap(map);

      expect(user.id, 2);
      expect(user.username, 'louis');
      expect(user.email, 'louis@mail.com');
      expect(user.password, 'abcdef');
      expect(user.profilePicture, 'avatar.jpg');
    });

    test('fromMap() tetap bekerja jika profilePicture null', () {
      final map = {
        'id': 3,
        'username': 'guest',
        'email': 'guest@mail.com',
        'password': 'guest123',
        'profilePicture': null,
      };

      final user = User.fromMap(map);

      expect(user.profilePicture, isNull);
    });

    test('copyWith() mengganti sebagian field', () {
      final user = User(
        id: 4,
        username: 'userlama',
        email: 'lama@mail.com',
        password: 'passwordlama',
        profilePicture: 'lama.png',
      );

      final updatedUser = user.copyWith(
        username: 'userbaru',
        email: 'baru@mail.com',
      );

      expect(updatedUser.id, 4);
      expect(updatedUser.username, 'userbaru');
      expect(updatedUser.email, 'baru@mail.com');
      expect(updatedUser.password, 'passwordlama');
      expect(updatedUser.profilePicture, 'lama.png');
    });

    test('copyWith() mengganti semua field', () {
      final user = User(
        id: 5,
        username: 'a',
        email: 'a@mail.com',
        password: 'a123',
      );

      final updatedUser = user.copyWith(
        id: 10,
        username: 'b',
        email: 'b@mail.com',
        password: 'b123',
        profilePicture: 'b.png',
      );

      expect(updatedUser.id, 10);
      expect(updatedUser.username, 'b');
      expect(updatedUser.email, 'b@mail.com');
      expect(updatedUser.password, 'b123');
      expect(updatedUser.profilePicture, 'b.png');
    });

    test('toMap() dan fromMap() konsisten (round-trip)', () {
      final user = User(
        id: 6,
        username: 'roundtrip',
        email: 'round@mail.com',
        password: 'round123',
        profilePicture: 'round.png',
      );

      final map = user.toMap();
      final result = User.fromMap(map);

      expect(result.id, user.id);
      expect(result.username, user.username);
      expect(result.email, user.email);
      expect(result.password, user.password);
      expect(result.profilePicture, user.profilePicture);
    });
  });

  group('Misi Model Unit Test', () {
    test('Constructor membuat objek Misi dengan benar', () {
      final misi = Misi(
        id: 1,
        nama: 'Menanam Pohon',
        deskripsi: 'Tanam 1 pohon',
        poin: 20,
      );

      expect(misi.id, 1);
      expect(misi.nama, 'Menanam Pohon');
      expect(misi.deskripsi, 'Tanam 1 pohon');
      expect(misi.poin, 20);
    });

    test('toMap() mengembalikan Map yang benar', () {
      final misi = Misi(
        id: 2,
        nama: 'Hemat Air',
        deskripsi: 'Kurangi pemakaian air',
        poin: 15,
      );

      final map = misi.toMap();

      expect(map, {
        'id': 2,
        'nama': 'Hemat Air',
        'deskripsi': 'Kurangi pemakaian air',
        'poin': 15,
      });
    });

    test('fromMap() membuat objek Misi dengan benar', () {
      final map = {
        'id': 3,
        'nama': 'Daur Ulang',
        'deskripsi': 'Daur ulang sampah',
        'poin': 25,
      };

      final misi = Misi.fromMap(map);

      expect(misi.id, 3);
      expect(misi.nama, 'Daur Ulang');
      expect(misi.deskripsi, 'Daur ulang sampah');
      expect(misi.poin, 25);
    });

    test('toJson() mengembalikan JSON yang benar', () {
      final misi = Misi(
        id: 4,
        nama: 'Tonton Iklan',
        deskripsi: 'Tonton iklan untuk mendapatkan poin',
        poin: 25,
      );

      final json = misi.toJson();

      expect(json, {
        'id': 4,
        'nama': 'Tonton Iklan',
        'deskripsi': 'Tonton iklan untuk mendapatkan poin',
        'poin': 25,
      });
    });

    test('fromJson() membuat objek Misi dengan benar', () {
      final json = {
        'id': 5,
        'nama': 'Donasi',
        'deskripsi': 'Donasi tanam pohon',
        'poin': 50,
      };

      final misi = Misi.fromJson(json);

      expect(misi.id, 5);
      expect(misi.nama, 'Donasi');
      expect(misi.deskripsi, 'Donasi tanam pohon');
      expect(misi.poin, 50);
    });
  });

  group('Berita Model Unit Test', () {
    test('fromJson() mem-parsing data lengkap dengan benar', () {
      final json = {
        'fields': {
          'title': 'Banjir di Jakarta',
          'body-html': '<p>Banjir melanda beberapa wilayah.</p>',
          'source': [
            {'name': 'ReliefWeb'}
          ],
          'date': {
            'created': '2024-01-01'
          }
        }
      };

      final berita = Berita.fromJson(json);

      expect(berita.judul, 'Banjir di Jakarta');
      expect(berita.isi, 'Banjir melanda beberapa wilayah.');
      expect(berita.sumber, 'ReliefWeb');
      expect(berita.tanggal, '2024-01-01');
    });

    test('fromJson() menggunakan body jika body-html kosong', () {
      final json = {
        'fields': {
          'title': 'Gempa Bumi',
          'body': 'Terjadi gempa bumi di wilayah timur.',
          'source': [
            {'name': 'BMKG'}
          ],
          'date': {
            'created': '2024-02-10'
          }
        }
      };

      final berita = Berita.fromJson(json);

      expect(berita.judul, 'Gempa Bumi');
      expect(berita.isi, 'Terjadi gempa bumi di wilayah timur.');
      expect(berita.sumber, 'BMKG');
      expect(berita.tanggal, '2024-02-10');
    });

    test('fromJson() memberi default isi jika body dan body-html kosong', () {
      final json = {
        'fields': {
          'title': 'Tanpa Isi',
        }
      };

      final berita = Berita.fromJson(json);

      expect(berita.judul, 'Tanpa Isi');
      expect(berita.isi, '(Tidak ada isi berita)');
      expect(berita.sumber, 'Tidak diketahui');
      expect(berita.tanggal, 'Tanggal tidak diketahui');
    });

    test('fromJson() memberi default judul jika title null', () {
      final json = {
        'fields': {
          'body': 'Isi berita tanpa judul',
        }
      };

      final berita = Berita.fromJson(json);

      expect(berita.judul, 'Tanpa Judul');
      expect(berita.isi, 'Isi berita tanpa judul');
      expect(berita.sumber, 'Tidak diketahui');
      expect(berita.tanggal, 'Tanggal tidak diketahui');
    });
  });

  group('Poin Model Test', () {
    test('toMap() mengembalikan Map dengan nilai yang benar', () {
      final poin = Poin(id: 1, total: 100);

      final map = poin.toMap();

      expect(map['id'], 1);
      expect(map['total'], 100);
    });

    test('fromMap() membuat objek Poin dengan benar', () {
      final Map<String, dynamic> map = {
        'id': 2,
        'total': 250,
      };

      final poin = Poin.fromMap(map);

      expect(poin.id, 2);
      expect(poin.total, 250);
    });

    test('fromMap() tetap berjalan saat id null', () {
      final Map<String, dynamic> map = {
        'id': null,
        'total': 50,
      };

      final poin = Poin.fromMap(map);

      expect(poin.id, isNull);
      expect(poin.total, 50);
    });

    test('toMap() tetap menyertakan id null', () {
      final poin = Poin(total: 75);

      final map = poin.toMap();

      expect(map.containsKey('id'), true);
      expect(map['id'], null);
      expect(map['total'], 75);
    });
  });

}
