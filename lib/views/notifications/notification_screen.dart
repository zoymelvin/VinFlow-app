import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  Future<void> _deleteAllNotifications() async {
    final collection = FirebaseFirestore.instance.collection('notifications');
    final snapshots = await collection.get();
    final batch = FirebaseFirestore.instance.batch();

    for (var doc in snapshots.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: CupertinoNavigationBar(
        middle: Text("Notifikasi Keuangan", 
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 16)),
        backgroundColor: Colors.white.withOpacity(0.9),
        border: const Border(bottom: BorderSide(color: Color(0xFFE2E8F0), width: 0.5)),
      ),
      body: Stack(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('notifications')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CupertinoActivityIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return _buildEmptyState();
              }

              // LOGIKA GROUPING BERDASARKAN TANGGAL
              Map<String, List<QueryDocumentSnapshot>> groupedNotifications = {};
              for (var doc in snapshot.data!.docs) {
                final data = doc.data() as Map<String, dynamic>;
                if (data['timestamp'] != null) {
                  DateTime date = (data['timestamp'] as Timestamp).toDate();
                  String dateKey = DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(date);
                  
                  if (groupedNotifications[dateKey] == null) {
                    groupedNotifications[dateKey] = [];
                  }
                  groupedNotifications[dateKey]!.add(doc);
                }
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
                itemCount: groupedNotifications.keys.length,
                itemBuilder: (context, index) {
                  String dateKey = groupedNotifications.keys.elementAt(index);
                  List<QueryDocumentSnapshot> notifications = groupedNotifications[dateKey]!;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Pemisah Tanggal
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
                        child: Text(dateKey, 
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w800, 
                            fontSize: 13, 
                            color: const Color(0xFF94A3B8)
                          )
                        ),
                      ),
                      // List Card Notifikasi pada tanggal tersebut
                      ...notifications.map((doc) => _buildNotificationCard(doc)),
                    ],
                  );
                },
              );
            },
          ),
          
          // Tombol Hapus Semua (Floating Style)
          _buildFloatingDeleteButton(context),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(QueryDocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;
    bool isRead = data['isRead'] ?? false;
    String type = data['type'] ?? 'warning';
    DateTime date = (data['timestamp'] as Timestamp).toDate();

    IconData iconData;
    Color color;

    switch (type) {
      case 'critical':
        iconData = CupertinoIcons.exclamationmark_octagon_fill;
        color = Colors.red;
        break;
      case 'income':
        iconData = CupertinoIcons.arrow_down_circle_fill;
        color = Colors.green;
        break;
      case 'expense':
        iconData = CupertinoIcons.arrow_up_circle_fill;
        color = Colors.blue;
        break;
      default:
        iconData = CupertinoIcons.bell_fill;
        color = Colors.orange;
    }

    return Dismissible(
      key: Key(doc.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(20)),
        child: const Icon(CupertinoIcons.trash, color: Colors.white),
      ),
      onDismissed: (_) => doc.reference.delete(),
      child: GestureDetector(
        onTap: () => doc.reference.update({'isRead': true}),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isRead ? Colors.white : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: isRead ? const Color(0xFFF1F5F9) : color.withOpacity(0.2)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(iconData, color: color, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(data['title'] ?? '', 
                          style: GoogleFonts.plusJakartaSans(fontWeight: isRead ? FontWeight.w700 : FontWeight.w800, fontSize: 14)),
                        Text(DateFormat('HH:mm').format(date), 
                          style: GoogleFonts.plusJakartaSans(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(data['message'] ?? '', 
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF64748B), height: 1.4)),
                    const SizedBox(height: 8),
                    // Informasi Tanggal di dalam Card
                    Text(DateFormat('dd MMM yyyy').format(date), 
                      style: GoogleFonts.plusJakartaSans(fontSize: 9, color: color.withOpacity(0.7), fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingDeleteButton(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('notifications').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const SizedBox();
        return Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () => _showDeleteConfirmation(context),
                icon: const Icon(CupertinoIcons.trash, size: 18),
                label: Text("Bersihkan Notifikasi", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 179, 13, 13),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  elevation: 8,
                ),
              ),
            ),
          ),
        );
      }
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text("Hapus Semua"),
        content: const Text("Yakin ingin menghapus seluruh notifikasi?"),
        actions: [
          CupertinoDialogAction(child: const Text("Batal"), onPressed: () => Navigator.pop(context)),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text("Hapus"),
            onPressed: () {
              _deleteAllNotifications();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(CupertinoIcons.bell_slash, size: 60, color: Colors.grey.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text("Belum ada kabar terbaru", 
            style: GoogleFonts.plusJakartaSans(color: Colors.grey, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}