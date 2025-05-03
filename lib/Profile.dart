// lib/ProfilePage.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swe463project/main.dart';          // mainColor
import 'models/palette_model.dart';
import 'services/auth_service.dart';
import 'widgets/palette_card.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  // ───────────────── animation & scaffold
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final AnimationController _drawerCtrl;
  late final Animation<Offset>   _drawerSlide;

  // ───────────────── auth listener
  late final StreamSubscription<User?> _authSub;

  // ───────────────── paging
  List<PaletteModel> myPalettes = [];
  DocumentSnapshot? lastDoc;
  bool isLoading   = false;
  bool hasMore     = true;
  bool isUserReady = false;
  final int pageSize = 6;
  final ScrollController _scrollCtrl = ScrollController();

  // ───────────────── lifecycle
  @override
  void initState() {
    super.initState();

    _drawerCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _drawerSlide = Tween(begin: const Offset(1, 0), end: Offset.zero).animate(
        CurvedAnimation(parent: _drawerCtrl, curve: Curves.easeInOut));

    _authSub =
        FirebaseAuth.instance.authStateChanges().listen((User? user) async {
          if (user != null) {
            setState(() => isUserReady = true);
            await _loadInitialPalettes();
          } else {
            setState(() {
              isUserReady = false;
              myPalettes.clear();
              lastDoc = null;
              hasMore = true;
            });
          }
        });

    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels >=
          _scrollCtrl.position.maxScrollExtent - 200 &&
          !isLoading &&
          hasMore) {
        _loadMorePalettes();
      }
    });
  }

  @override
  void dispose() {
    _authSub.cancel();
    _drawerCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  // ───────────────── Firestore helpers
  PaletteModel _docToPalette(
      QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    return PaletteModel(
      id: doc.id,
      colorHexCodes: List<String>.from(d['colors']),
      likes: d['likes'] ?? 0,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdBy: d['createdBy'] ?? 'Lawwen',
      userName : d['userName']  ?? 'Lawwen',
      hues: (d['hues'] as List<dynamic>).map((e) => (e as num).toDouble()).toList(), likedBy: [],
    );
  }

  Future<void> _loadInitialPalettes() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      final q = FirebaseFirestore.instance
          .collection('palettes')
          .where('createdBy', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .orderBy('createdAt', descending: true)
          .limit(pageSize);

      final snap = await q.get();
      myPalettes = snap.docs.map(_docToPalette).toList();
      lastDoc    = snap.docs.isNotEmpty ? snap.docs.last : null;
      hasMore    = snap.size == pageSize;
    } catch (e, s) {
      debugPrint('Profile initial-load error ➜ $e\n$s');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _loadMorePalettes() async {
    if (!hasMore || isLoading || lastDoc == null || !mounted) return;
    setState(() => isLoading = true);

    try {
      final q = FirebaseFirestore.instance
          .collection('palettes')
          .where('createdBy', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .orderBy('createdAt', descending: true)
          .startAfterDocument(lastDoc!)
          .limit(pageSize);

      final snap = await q.get();
      final more = snap.docs.map(_docToPalette).toList();

      myPalettes.addAll(more);
      lastDoc = snap.docs.isNotEmpty ? snap.docs.last : lastDoc;
      hasMore = snap.size == pageSize;
    } catch (e, s) {
      debugPrint('Profile load-more error ➜ $e\n$s');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _refreshPalettes() => _loadInitialPalettes();

  // ───────────────── UI helpers
  void _openDrawer() {
    _scaffoldKey.currentState?.openEndDrawer();
    _drawerCtrl.forward();
  }

  String _timeAgo(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inDays  >= 365) return '${(diff.inDays / 365).floor()}y ago';
    if (diff.inDays  >=   1) return '${diff.inDays}d ago';
    if (diff.inHours >=   1) return '${diff.inHours}h ago';
    return '${diff.inMinutes}m ago';
  }

  // ───────────────── build ───────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (!isUserReady || user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      key: _scaffoldKey,
      endDrawerEnableOpenDragGesture: true,
      endDrawer: SlideTransition(position: _drawerSlide, child: _drawer(user)),
      body: SafeArea(
        child: Column(
          children: [
            _topBar(user),
            const SizedBox(height: 36),
            _userInfo(user),
            const SizedBox(height: 36),
            _paletteGrid(),
          ],
        ),
      ),
    );
  }

  Widget _userInfo(User user) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20.0),
    child: Column(
      children: [
        const CircleAvatar(
          radius: 30,
          backgroundColor: Colors.black54,
          child: Icon(Icons.person, size: 40, color: Colors.grey),
        ),
        const SizedBox(height: 18),
        Text(user.displayName ?? '',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            )),
        const SizedBox(height: 4),
        Text(user.email ?? '', style: const TextStyle(color: Colors.grey)),
      ],
    ),
  );

  // ───────────────── drawer widget ───────────────────────────────────
  Widget _drawer(User user) => Drawer(
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    backgroundColor: Colors.white.withOpacity(0.95),
    child: SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DrawerHeader(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.black54,
                  child: Icon(Icons.person, size: 40, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                Text(user.displayName ?? '',
                    style: const TextStyle(fontSize: 18)),
                Text(user.email ?? '',
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            onTap: () {},
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text('Sign Out'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.red,
                backgroundColor: Colors.grey.withOpacity(0.15),
                elevation: 0,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => AuthService().signout(context: context),
            ),
          ),
        ],
      ),
    ),
  );

  // ───────────────── top bar widget ──────────────────────────────────
  Widget _topBar(User user) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(width: 48),
        Image.asset('assets/images/logo.png', height: 40),
        IconButton(icon: const Icon(Icons.menu), onPressed: _openDrawer),
      ],
    ),
  );

  // ───────────────── palette grid card ───────────────────────────────
  Widget _paletteGrid() => Expanded(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.5),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(29), topRight: Radius.circular(29)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 10,
                offset: const Offset(0, -1)),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('My Colors',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800])),
              const SizedBox(height: 12),
              Expanded(
                child: RefreshIndicator(
                  displacement: 0,
                  color: mainColor,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  onRefresh: _refreshPalettes,
                  child: myPalettes.isEmpty && isLoading
                      ? const Center(
                      child: CircularProgressIndicator(color: mainColor))
                      : GridView.builder(
                    controller: _scrollCtrl,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: myPalettes.length,
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.7,
                    ),
                    itemBuilder: (context, i) {
                      final p = myPalettes[i];
                      return PaletteCard(
                        palette: p,
                        timeAgoText: _timeAgo(p.createdAt),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
