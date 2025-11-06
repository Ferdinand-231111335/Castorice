import 'dart:io'; 
import 'package:flutter/material.dart';
import 'package:project_kelompok/screen/tiket_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart'; 
import 'package:path_provider/path_provider.dart'; 
import 'package:path/path.dart' as p; 

import '../database/evergreen_db.dart';
import '../model/user_model.dart';
import 'signin.dart';
import '../main.dart';

class SettingsPage extends StatefulWidget {
  final ThemeChangeCallback toggleTheme;
  const SettingsPage({super.key, required this.toggleTheme}); 

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isDarkMode = false;
  bool isNotificationEnabled = true;
  String username = 'Memuat...';
  String email = 'Memuat...';
  String? profilePicturePath; // Tambahkan ini
  int? userId;
  final EvergreenDb db = EvergreenDb();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if(mounted) {
      setState(() {
        isDarkMode = prefs.getBool('isDarkMode') ?? false;
        isNotificationEnabled = prefs.getBool('isNotificationEnabled') ?? true;
        username = prefs.getString('username') ?? 'Pengguna';
        email = prefs.getString('email') ?? 'email@contoh.com';
        userId = prefs.getInt('userId');
        profilePicturePath = prefs.getString('profilePicture'); // Muat path foto profil
      });
    }
  }

  void _toggleDarkMode(bool value) async {
    setState(() {
      isDarkMode = value;
    });

    widget.toggleTheme(value);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value); 
  }
  
  void _toggleNotification(bool value) async {
    setState(() {
      isNotificationEnabled = value;
    });
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isNotificationEnabled', value);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Notifikasi ${value ? 'diaktifkan' : 'dinonaktifkan'}")),
      );
    }
  }

  void _resetDatabase() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Reset Database"),
          content: const Text("Anda yakin ingin menghapus semua data (user, misi, dan poin)? Anda akan dikeluarkan dari aplikasi. Tindakan ini tidak dapat dibatalkan."),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () async {
                await db.resetDatabase();
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();

                if (mounted) {
                  Navigator.of(context).pop(); 
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => SignIn(toggleTheme: widget.toggleTheme)),
                    (route) => false,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Database berhasil di-reset. Silakan daftar kembali.")),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Reset", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // --- Halaman Edit Profil Pengguna yang Berfungsi ---
  void _showProfilePage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditProfilePage(
          currentUsername: username,
          currentEmail: email,
          currentProfilePicturePath: profilePicturePath, // Kirim path gambar
          userId: userId,
          onProfileUpdated: (newUsername, newEmail, newProfilePicturePath) {
            setState(() {
              username = newUsername;
              email = newEmail;
              profilePicturePath = newProfilePicturePath;
            });
          },
        ),
      ),
    );
  }

  void _showChangePasswordPage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text("Keamanan Akun"),
            backgroundColor: Colors.green,
          ),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const TextField(
                  decoration: InputDecoration(labelText: "Password Lama"),
                  obscureText: true,
                ),
                const TextField(
                  decoration: InputDecoration(labelText: "Password Baru"),
                  obscureText: true,
                ),
                const TextField(
                  decoration: InputDecoration(labelText: "Konfirmasi Password Baru"),
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Fitur ganti password belum diimplementasi")),
                    );
                  },
                  child: const Text("Ubah Password"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pengaturan"),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            
            // ===================================
            // KATEGORI: AKUN & PRIVASI
            // ===================================
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Text(
                "Akun & Privasi",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.account_circle),
              title: const Text("Profil Pengguna"),
              subtitle: Text(username),
              onTap: () => _showProfilePage(context),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.security),
              title: const Text("Keamanan Akun"),
              subtitle: const Text("Ganti password"),
              onTap: () => _showChangePasswordPage(context),
            ),
            const Divider(),
            
            // ===================================
            // KATEGORI: TAMPILAN
            // ===================================
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Text(
                "Tampilan",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            SwitchListTile(
              title: const Text("Mode Gelap"),
              subtitle: const Text("Mengubah tema aplikasi menjadi gelap secara instan"),
              secondary: const Icon(Icons.brightness_4),
              value: isDarkMode,
              onChanged: _toggleDarkMode, 
            ),
            const Divider(),

            // ===================================
            // KATEGORI: TIKET
            // ===================================
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Text(
                "Tiket",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text("Riwayat Penukaran"),
              subtitle: const Text("Lihat hasil tukar poin Anda"),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const TicketPage()),
                );
              },
            ),
            const Divider(),
            
            // ===================================
            // KATEGORI: UMUM
            // ===================================
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Text(
                "Umum",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            
            SwitchListTile(
              title: const Text("Notifikasi"),
              subtitle: const Text("Izinkan aplikasi mengirim pemberitahuan"),
              secondary: const Icon(Icons.notifications),
              value: isNotificationEnabled,
              onChanged: _toggleNotification,
            ),
            const Divider(),
            
            // ===================================
            // KATEGORI: DATA & PRIVASI
            // ===================================
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Text(
                "Data & Privasi",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            ListTile(
              title: const Text("Reset Data Aplikasi"),
              subtitle: const Text("Hapus semua data lokal (user, misi, poin) dan keluar."),
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              onTap: _resetDatabase,
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }
}

// =========================================================================
// WIDGET BARU UNTUK EDIT PROFIL DENGAN FOTO PROFIL
// =========================================================================
class EditProfilePage extends StatefulWidget {
  final String currentUsername;
  final String currentEmail;
  final String? currentProfilePicturePath; // Terima path gambar
  final int? userId;
  final Function(String, String, String?) onProfileUpdated; // Tambah path gambar ke callback

  const EditProfilePage({
    super.key,
    required this.currentUsername,
    required this.currentEmail,
    this.currentProfilePicturePath, // Tambah ini
    required this.userId,
    required this.onProfileUpdated,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final EvergreenDb db = EvergreenDb();
  File? _imageFile; // Untuk menyimpan gambar yang dipilih

  @override
  void initState() {
    super.initState();
    usernameController.text = widget.currentUsername;
    emailController.text = widget.currentEmail;
    if (widget.currentProfilePicturePath != null && widget.currentProfilePicturePath!.isNotEmpty) {
      _imageFile = File(widget.currentProfilePicturePath!);
    }
  }
  
  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _showImageSourceActionSheet(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Kamera'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeri'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<String?> _saveImageLocally(File image) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final String fileName = p.basename(image.path);
      final String localPath = p.join(directory.path, fileName);
      final File newImage = await image.copy(localPath);
      return newImage.path;
    } catch (e) {
      print("Error saving image: $e");
      return null;
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    final newUsername = usernameController.text.trim();
    final newEmail = emailController.text.trim();
    String? newProfilePicturePath = widget.currentProfilePicturePath;

    if (widget.userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error: User ID tidak ditemukan.")),
        );
      }
      return;
    }
    
    final oldUser = await db.getUserById(widget.userId!);
    
    if (oldUser == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error: Data user tidak valid.")),
        );
      }
      return;
    }

    if (_imageFile != null) {
      newProfilePicturePath = await _saveImageLocally(_imageFile!);
      if (newProfilePicturePath == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Gagal menyimpan gambar profil.")),
          );
        }
        return;
      }
    }

    final updatedUser = oldUser.copyWith(
      username: newUsername,
      email: newEmail,
      profilePicture: newProfilePicturePath, 
    );

    final rowsAffected = await db.updateUser(updatedUser);

    if (rowsAffected > 0) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', newUsername);
      await prefs.setString('email', newEmail);
      if (newProfilePicturePath != null) {
        await prefs.setString('profilePicture', newProfilePicturePath);
      } else {
        await prefs.remove('profilePicture');
      }
      
      widget.onProfileUpdated(newUsername, newEmail, newProfilePicturePath);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profil berhasil diperbarui!")),
        );
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal memperbarui profil di database.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profil"),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: GestureDetector(
                  onTap: () => _showImageSourceActionSheet(context),
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: _imageFile != null && _imageFile!.existsSync()
                            ? FileImage(_imageFile!)
                            : null,
                        child: _imageFile == null || !_imageFile!.existsSync()
                            ? Icon(Icons.person, size: 50, color: Colors.grey.shade600)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              
              TextFormField(
                controller: usernameController,
                decoration: const InputDecoration(
                  labelText: "Username",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Username tidak boleh kosong";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Email tidak boleh kosong";
                  }
                  if (!value.contains('@')) {
                    return "Masukkan email yang valid";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              
              ElevatedButton(
                onPressed: _updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text(
                  "Simpan Perubahan",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}