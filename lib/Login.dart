import 'package:flutter/material.dart';
import 'package:swe463project/services/auth_service.dart';

import 'main.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import 'Favorite.dart';
import 'Home.dart'; // for mainCo
import 'PaletteCreation.dart';
import 'Popular.dart';
import 'Profile.dart'; // lor

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    PopularPage(),
    HomeScreen(),
    FavoritePage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    // We disable changing the selected tab when tapping index 2 (Add button)
    if (index == 2) return;
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashFactory: NoSplash.splashFactory,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: mainColor,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
          elevation: 10,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined), label: 'Home'),
            const BottomNavigationBarItem(
                icon: Icon(Icons.whatshot_outlined), label: 'Popular'),
            // BottomNavigationBarItem(
            //   // Custom styling for the "Add" button.
            //   icon: Container(
            //     width: 79,
            //     height: 45,
            //     decoration: BoxDecoration(
            //       color: const Color(0xffAAC4FF),
            //       borderRadius: BorderRadius.circular(15),
            //       boxShadow: [
            //         BoxShadow(
            //             color: Colors.black.withOpacity(0.4),
            //             blurRadius: 4,
            //             offset: Offset(0, 4))
            //       ],
            //     ),
            //     child: GestureDetector(
            //       onTap: () {
            //         showModalBottomSheet(
            //           context: context,
            //           isScrollControlled: true,
            //           backgroundColor: Colors
            //               .transparent, // Let custom container show its round corners
            //           builder: (BuildContext context) {
            //             return DraggableScrollableSheet(
            //               initialChildSize: 0.86,
            //               minChildSize: 0.5,
            //               maxChildSize: 1.0,
            //               builder: (BuildContext context,
            //                   ScrollController scrollController) {
            //                 return Container(
            //                   decoration: const BoxDecoration(
            //                     color: Colors.white,
            //                     borderRadius: BorderRadius.vertical(
            //                         top: Radius.circular(20)),
            //                   ),
            //                   child: CreatePaletteModal(),
            //                 );
            //               },
            //             );
            //           },
            //         );
            //       },
            //       child: Column(
            //         mainAxisAlignment: MainAxisAlignment.center,
            //         children: const [
            //           Icon(Icons.add, color: Colors.black),
            //           // Text(
            //           //   'Add',
            //           //   style: TextStyle(color: Colors.black, fontSize: 10),
            //           // ),
            //         ],
            //       ),
            //     ),
            //   ),
            //   label: '',
            // ),
            const BottomNavigationBarItem(
                icon: Icon(Icons.favorite_outline), label: 'Favorite'),
            const BottomNavigationBarItem(
                icon: Icon(Icons.person_2_outlined), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 140),
          Image.asset(
            'assets/images/logo.png',
            height: 160,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Form(
                child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'Email',
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 18),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: mainColor.withOpacity(0.4), width: 2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: mainColor, width: 2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      hintStyle: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    onChanged: (String value) {},
                    validator: (value) {
                      return value!.isEmpty ? 'Please enter email' : null;
                    },
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: TextFormField(
                    controller: passwordController,
                    keyboardType: TextInputType.visiblePassword,
                    decoration: InputDecoration(
                      hintText: 'password',
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 18),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: mainColor.withOpacity(0.4), width: 2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: mainColor, width: 2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      hintStyle: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    onChanged: (String value) {},
                    validator: (value) {
                      return value!.isEmpty ? 'Please enter password' : null;
                    },
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: ElevatedButton(
                    onPressed: () async {
                      await AuthService().signIn(
                        email: emailController.text,
                        password: passwordController.text,
                        context: context,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mainColor,
                      foregroundColor: Colors.white,
                      elevation: 8,
                      shadowColor: Colors.grey.withOpacity(0.5),
                      minimumSize: const Size(double.infinity, 60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      textStyle: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    child: const Text(
                      "Log In",
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
                    ),
                  ),
                )
              ],
            )),
          )
        ],
      ),
    );
  }
}
