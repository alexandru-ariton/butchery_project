// ignore_for_file: unused_label, prefer_const_constructors_in_immutables

import 'package:custom_navigation_bar/custom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:gastrogrid_app/aplicatie_client/pagini/Folder_Home/pagina_home.dart';
import 'package:gastrogrid_app/aplicatie_client/pagini/Folder_Orders/pagina_order.dart';
import 'package:gastrogrid_app/aplicatie_client/pagini/Folder_Profile/pagina_profil.dart';

class BaraNavigare extends StatefulWidget {
  BaraNavigare({super.key});

  @override
  State<BaraNavigare> createState() => _BaraNavigareState();
}

class _BaraNavigareState extends State<BaraNavigare> {

  PageController pageController = PageController();


   List<IconData> listOfIcons = [
    Icons.home_rounded,
    Icons.favorite_rounded,
    Icons.settings_rounded,
    Icons.person_rounded,
  ];


  int _selectedIndex = 0;

  List<Widget> pageList = [
    PaginaHome(),
    OrderPage(),
    ProfilePage(),
    
  ];

  void onPageChanged(int index){
      setState(() {
        _selectedIndex = index;
      });
  }

    void onItemTaped(int i){
      setState(() {
        pageController.jumpToPage(i);
      });
  }


  @override
  Widget build(BuildContext context) {
   
    return SafeArea(
    
      child: Scaffold(
       
      
        body:PageView(
          controller: pageController,
          children: pageList,
          onPageChanged: onPageChanged,
      
        ),
        bottomNavigationBar:CustomNavigationBar(

            backgroundColor: Theme.of(context).colorScheme.onPrimary,
            iconSize: 26.0,
            borderRadius: Radius.circular(5),
            selectedColor: Color.fromARGB(255, 142, 241, 103),
            unSelectedColor: Color.fromARGB(255, 62, 134, 230),
            strokeColor: Colors.white,
            
            items:[
              CustomNavigationBarItem(
                icon: Icon(Icons.home)
              ),
              
               CustomNavigationBarItem(
                icon: Icon(Icons.receipt)
              ),
              CustomNavigationBarItem(
                icon: Icon(Icons.person)
              ),
            ],
            onTap: onItemTaped,
            currentIndex: _selectedIndex,
            ),
       
      
       
      ),
    );
  }
}