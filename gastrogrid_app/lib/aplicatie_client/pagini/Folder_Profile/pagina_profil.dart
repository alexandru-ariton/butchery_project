// ignore_for_file: unused_import, prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_unnecessary_containers


import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gastrogrid_app/aplicatie_client/pagini/Folder_Profile/screens/edit_screen.dart';
import 'package:gastrogrid_app/aplicatie_client/pagini/Folder_Profile/screens/payment_screen.dart';
import 'package:gastrogrid_app/aplicatie_client/pagini/Folder_Profile/screens/settings_screen.dart';
import 'package:gastrogrid_app/aplicatie_client/pagini/Folder_Profile/screens/support_screen.dart';
import 'package:gastrogrid_app/aplicatie_client/pagini/Folder_Profile/widgets/setting_item.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  bool isDarkMode = false;



  @override
  Widget build(BuildContext context) {
    return Scaffold(
     backgroundColor: Theme.of(context).colorScheme.background,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
             
             
           
              Padding(
                padding: EdgeInsets.all( 8),
                child: SizedBox(
                  width: double.infinity,
                  child: Row(
                    children: [
                      
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Test Test",
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 25),
                          GestureDetector(
                            onTap: () {
                              Navigator.push<void>(
    context,
    MaterialPageRoute<void>(
      builder: (BuildContext context) => const EditAccountScreen(),
    ),
  );
                            },
                            child: Container(
                              child: Text(
                                "+407563214",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: const Color.fromARGB(255, 0, 0, 0),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                     
                      
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
         
              
              const SizedBox(height: 20),
              SettingItem(
                title: "Paymet",
                icon: Icons.payment_outlined,
                bgColor: Colors.blue.shade100,
                iconColor: Colors.blue,
                onPressed: () {
                  Navigator.push<void>(
    context,
    MaterialPageRoute<void>(
      builder: (BuildContext context) =>  PaymentPage(),
    ),
  );
                },
              ),
               const SizedBox(height: 20),
              SettingItem(
                title: "Profile",
                icon: Icons.person,
                bgColor: Colors.blue.shade100,
                iconColor: Colors.blue,
                onPressed: () {
                       Navigator.push<void>(
    context,
    MaterialPageRoute<void>(
      builder: (BuildContext context) => const EditAccountScreen(),
    ),
  );
                },
              ),
               const SizedBox(height: 20),
              SettingItem(
                title: "Settings",
                icon: Icons.settings,
                bgColor: Colors.blue.shade100,
                iconColor: Colors.blue,
               onPressed: () {
                Navigator.push<void>(
    context,
    MaterialPageRoute<void>(
      builder: (BuildContext context) =>  SettingsPage(),
    ),
  );
               },
              ),
             
              const SizedBox(height: 20),
              SettingItem(
                title: "About",
                icon: Icons.info,
                bgColor: Color.fromARGB(255, 237, 180, 10),
                iconColor: Color.fromARGB(255, 107, 82, 18),
                onPressed: () {
                  Navigator.push<void>(
    context,
    MaterialPageRoute<void>(
      builder: (BuildContext context) => const EditAccountScreen(),
    ),
  );
                },
              ),
               const SizedBox(height: 20),
              SettingItem(
                title: "Support",
                icon: Icons.help,
                bgColor: Colors.blue.shade100,
                iconColor: Colors.blue,
                onPressed: () {
                 Navigator.push<void>(
    context,
    MaterialPageRoute<void>(
      builder: (BuildContext context) =>  SupportPage(),
    ),
  );
                },
              ),
               
            ],
          ),
        ),
      ),
    );
  }
}