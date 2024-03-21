
// ignore_for_file: prefer_const_constructors, unused_import, unnecessary_string_interpolations, prefer_const_literals_to_create_immutables

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:gastrogrid_app/aplicatie_client/pagini/Folder_Profile/widgets/edit_item.dart';

class EditAccountScreen extends StatefulWidget {
  const EditAccountScreen({super.key});

  @override
  State<EditAccountScreen> createState() => _EditAccountScreenState();
}

class _EditAccountScreenState extends State<EditAccountScreen> {
  String gender = "man";

   void signUserOut(){
      FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      appBar: AppBar(
       backgroundColor: Colors.blueGrey,
        title: Text("Profile"),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_outlined),
        ),
        leadingWidth: 80,
        
      ),
         body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextInputField('First name'),
              _buildTextInputField('Last name'),
              _buildTextInputField('E-mail'),
             
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                 ElevatedButton.icon(
                 
      onPressed: () {
        signUserOut();
      },
      icon: Icon(Icons.logout_rounded,color: Colors.red,),
      label: Text("Log Out",style: TextStyle(color: Colors.red),),
      
    ),
    ElevatedButton.icon(
      onPressed: () {
        
      },
      icon: Icon(Icons.delete_forever,color: Colors.red,),
      label: Text("Delete Account",style: TextStyle(color: Colors.red),),
    ),
                ],
              ),
            ],
          ),
        ),
    );
  }
}

Widget _buildTextInputField(String title) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      padding: EdgeInsets.symmetric(horizontal: 15),
     
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          SizedBox(
            height: 60,
            
            child: TextFormField(
              
              style: TextStyle(
                color: Colors.white,
               decoration:TextDecoration.none,
               textBaseline: null
              ),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10)
                ),
                
                
                labelText: '$title',
                filled: true,
               
              ),
            ),
          ),
        ],
      ),
    );
  }
