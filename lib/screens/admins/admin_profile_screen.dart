import 'package:flutter/material.dart';

class AdminProfileScreen extends StatelessWidget {
  const AdminProfileScreen({Key? key}) : super(key: key);

  final Color primaryColor = const Color(0xFF08A8B1); // Tosca
  final Color secondaryColor = const Color(0xFFF19E23); // Orange

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primaryColor,
                  primaryColor.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.3),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: secondaryColor,
                      width: 2,
                    ),
                  ),
                  child: Image.asset(
                    'images/Logo.png',
                    height: 80,
                    width: 320,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Medicare',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    color: secondaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 32),
          _buildSection(
            'Tentang Aplikasi',
            'Medicare adalah aplikasi manajemen rumah sakit yang memudahkan interaksi antara dokter dan pasien. Aplikasi ini membantu dalam penjadwalan appointment, manajemen rekam medis, dan komunikasi yang lebih baik antara staff medis dan pasien.',
            Icons.info_outline,
          ),
          SizedBox(height: 24),
          _buildSection(
            'Tim Pengembang',
            '',
            Icons.people_outline,
            children: [
              _buildDeveloperCard(
                'Andhika Fajar Prayoga',
                'UI/UX Designer',
                'images/andhika.jpg',
              ),
              _buildDeveloperCard(
                'Bayu Ramdhan Ardiyanto',
                'Load Developer',
                'images/bayu.jpeg',
              ),
            ],
          ),
          SizedBox(height: 24),
          _buildSection(
            'Kontak',
            '',
            Icons.contact_mail_outlined,
            children: [
              _buildContactTile(
                Icons.email,
                'Email',
                'support@medicare.com',
              ),
              _buildContactTile(
                Icons.phone,
                'Phone',
                '+62 123 456 789',
              ),
              _buildContactTile(
                Icons.location_on,
                'Alamat',
                'Jl. Contoh No. 123, Jakarta, Indonesia',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content, IconData icon,
      {List<Widget>? children}) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: primaryColor.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: primaryColor),
              SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          if (content.isNotEmpty) ...[
            SizedBox(height: 12),
            Text(
              content,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                height: 1.5,
              ),
              textAlign: TextAlign.justify,
            ),
          ],
          if (children != null) ...[
            SizedBox(height: 16),
            ...children,
          ],
        ],
      ),
    );
  }

  Widget _buildDeveloperCard(String name, String role, String imagePath) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(12),
        leading: CircleAvatar(
          radius: 30,
          backgroundImage: AssetImage(imagePath),
          backgroundColor: primaryColor.withOpacity(0.1),
        ),
        title: Text(
          name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        subtitle: Container(
          margin: EdgeInsets.only(top: 4),
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: secondaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            role,
            style: TextStyle(
              color: secondaryColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactTile(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: primaryColor),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: primaryColor,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey[600],
        ),
      ),
    );
  }
}
