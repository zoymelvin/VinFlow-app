import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vinflow/views/dashboard/widgets/transaction_list.dart';
import 'package:vinflow/views/notifications/notification_screen.dart';
import 'package:vinflow/views/widgets/side_menu.dart';
import 'package:vinflow/views/history/history_screen.dart'; // Import HistoryScreen
import 'widgets/header_section.dart';
import 'widgets/balance_card.dart';
import 'widgets/menu_grid.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  double _scrollOffset = 0.0;

  String _getTimeGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour <= 11) {
      return "Selamat Pagi,";
    } else if (hour > 11 && hour <= 15) {
      return "Selamat Siang,";
    } else if (hour > 15 && hour <= 18) {
      return "Selamat Sore,";
    } else {
      return "Selamat Malam,";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const SideMenu(),
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          Transform.translate(
            offset: Offset(0, -_scrollOffset.clamp(0.0, 200.0)),
            child: const HeaderSection(),
          ),

          SafeArea(
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is ScrollUpdateNotification) {
                  setState(() {
                    _scrollOffset = notification.metrics.pixels;
                  });
                }
                return true;
              },
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => _scaffoldKey.currentState?.openDrawer(),
                            child: StreamBuilder<DocumentSnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('profile')
                                  .doc('user_profile')
                                  .snapshots(),
                              builder: (context, snapshot) {
                                String userName = "User VinFlow";
                                String? profileUrl;

                                if (snapshot.hasData && snapshot.data!.exists) {
                                  final data = snapshot.data!.data() as Map<String, dynamic>;
                                  userName = data['name'] ?? userName;
                                  profileUrl = data['profileImageUrl'];
                                }

                                return Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: Colors.white.withOpacity(0.5), 
                                            width: 2),
                                      ),
                                      child: CircleAvatar(
                                        radius: 22,
                                        backgroundColor: Colors.white24,
                                        backgroundImage: (profileUrl != null && profileUrl.isNotEmpty)
                                            ? NetworkImage(profileUrl)
                                            : null,
                                        child: (profileUrl == null || profileUrl.isEmpty)
                                            ? const Icon(CupertinoIcons.person_fill, 
                                                color: Colors.white, size: 22)
                                            : null,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _getTimeGreeting(),
                                          style: GoogleFonts.plusJakartaSans(
                                              color: Colors.white70, 
                                              fontSize: 12, 
                                              fontWeight: FontWeight.w500),
                                        ),
                                        Text(
                                          userName,
                                          style: GoogleFonts.plusJakartaSans(
                                              color: Colors.white,
                                              fontSize: 17,
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('notifications')
                                .where('isRead', isEqualTo: false)
                                .snapshots(),
                            builder: (context, snapshot) {
                              int unreadCount = snapshot.data?.docs.length ?? 0;

                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                      builder: (context) => const NotificationScreen(),
                                    ),
                                  );
                                },
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.15),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        CupertinoIcons.bell_fill,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                    if (unreadCount > 0)
                                      Positioned(
                                        right: -2,
                                        top: -2,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFF43F5E), 
                                            shape: BoxShape.circle,
                                          ),
                                          constraints: const BoxConstraints(
                                            minWidth: 18,
                                            minHeight: 18,
                                          ),
                                          child: Center(
                                            child: Text(
                                              unreadCount > 9 ? "9+" : "$unreadCount",
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: BalanceCard()),
                  const MenuGrid(),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Aktivitas Terbaru",
                                  style: GoogleFonts.plusJakartaSans(
                                      fontSize: 19,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF0F172A))),
                              const SizedBox(height: 2),
                              Container(
                                width: 40,
                                height: 3,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF007BFF),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              )
                            ],
                          ),
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            child: Text("Lihat Semua",
                                style: GoogleFonts.plusJakartaSans(
                                    color: const Color(0xFF007BFF),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700)),
                            onPressed: () {
                              // NAVIGASI KE RIWAYAT
                              Navigator.push(
                                context,
                                CupertinoPageRoute(builder: (context) => const HistoryScreen()),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const TransactionSection(),
                  const SliverToBoxAdapter(child: SizedBox(height: 80)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}