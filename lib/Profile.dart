import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swe463project/main.dart';
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final AnimationController _drawerAnimationController;
  late final Animation<Offset> _drawerSlide;

  List<PaletteModel> myPalettes = [];
  DocumentSnapshot? lastDoc;
  bool isLoading = false;
  bool hasMore = true;
  bool isUserReady = false;
  final int pageSize = 6;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _drawerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _drawerSlide = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _drawerAnimationController,
      curve: Curves.easeInOut,
    ));

    _waitForUserAndLoad();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200 &&
          !isLoading &&
          hasMore) {
        _loadMorePalettes();
      }
    });
  }

  Future<void> _waitForUserAndLoad() async {
    await Future.delayed(Duration(milliseconds: 500));
    if (mounted && FirebaseAuth.instance.currentUser != null) {
      setState(() => isUserReady = true);
      _loadInitialPalettes();
    }
  }

  Future<void> _loadInitialPalettes() async {
    setState(() => isLoading = true);
    final query = FirebaseFirestore.instance
        .collection('palettes')
        .where('createdBy', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .orderBy('createdAt', descending: true)
        .limit(pageSize);

    final snapshot = await query.get();
    final docs = snapshot.docs;

    setState(() {
      myPalettes = docs.map((d) {
        final data = d.data();
        return PaletteModel(
            id: d.id,
            colorHexCodes: List<String>.from(data['colors']),
            likes: data['likes'] ?? 0,
            createdAt:
            (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
            createdBy: (data['createdBy'] as String?)?.toString() ?? "Lawwen",
            userName: (data['userName'] as String?)?.toString() ?? "Lawwen",
            hues: (data['hues'] as List<dynamic>).map((e) => (e as num).toDouble()).toList(),

        );
      }).toList();

      lastDoc = docs.isNotEmpty ? docs.last : null;
      hasMore = docs.length == pageSize;
      isLoading = false;
    });
  }

  Future<void> _loadMorePalettes() async {
    if (!hasMore || isLoading || lastDoc == null) return;
    setState(() => isLoading = true);

    final query = FirebaseFirestore.instance
        .collection('palettes')
        .where('createdBy', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .orderBy('createdAt', descending: true)
        .startAfterDocument(lastDoc!)
        .limit(pageSize);

    final snapshot = await query.get();
    final docs = snapshot.docs;

    final morePalettes = docs.map((d) {
      final data = d.data();
      return PaletteModel(
        id: d.id,
        colorHexCodes: List<String>.from(data['colors']),
        likes: data['likes'] ?? 0,
        createdAt:
        (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        createdBy: (data['createdBy'] as String?)?.toString() ?? "Lawwen",
        userName: (data['userName'] as String?)?.toString() ?? "Lawwen",
        hues: (data['hues'] as List<dynamic>).map((e) => (e as num).toDouble()).toList(),

      );
    }).toList();

    setState(() {
      myPalettes.addAll(morePalettes);
      lastDoc = docs.isNotEmpty ? docs.last : lastDoc;
      hasMore = docs.length == pageSize;
      isLoading = false;
    });
  }

  Future<void> _refreshPalettes() async {
    setState(() {
      myPalettes.clear();
      lastDoc = null;
      hasMore = true;
    });
    await _loadInitialPalettes();
  }

  String timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays >= 365) {
      final years = (diff.inDays / 365).floor();
      return '${years}y ago';
    } else if (diff.inDays >= 1) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours >= 1) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inMinutes}m ago';
    }
  }

  void _openEndDrawer() {
    _scaffoldKey.currentState?.openEndDrawer();
    _drawerAnimationController.forward();
  }

  @override
  void dispose() {
    _drawerAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (!isUserReady || user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      endDrawerEnableOpenDragGesture: true,
      endDrawer: SlideTransition(
        position: _drawerSlide,
        child: Drawer(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
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
                      Text(user.displayName ?? '', style: const TextStyle(fontSize: 18)),
                      Text(user.email ?? '', style: const TextStyle(color: Colors.grey)),
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
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => AuthService().signout(context: context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 48),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Center(
                          child: Image.asset('assets/images/logo.png', height: 40),
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: _openEndDrawer,
                  ),
                ],
              ),
            ),
            Padding(
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
            ),
            const SizedBox(height: 36),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0.5),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(29),
                      topRight: Radius.circular(29),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 10,
                        offset: const Offset(0, -1),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16,16,16,0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('My Colors',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            )),
                        const SizedBox(height: 12),
                        Expanded(
                          child: RefreshIndicator(
                            displacement: 0,
                            color: mainColor,
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                            onRefresh: _refreshPalettes,
                            child: myPalettes.isEmpty && isLoading
                                ? const Center(child: CircularProgressIndicator(color: mainColor,))
                                : GridView.builder(
                              controller: _scrollController,
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: myPalettes.length,
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                                childAspectRatio: 0.7,
                              ),
                              itemBuilder: (context, index) {
                                final palette = myPalettes[index];
                                return PaletteCard(
                                  palette: palette,
                                  timeAgoText: timeAgo(palette.createdAt),
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
            ),
          ],
        ),
      ),
    );
  }
}
