import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gastrogrid_app/themes/theme_provider.dart';
import 'package:provider/provider.dart';


class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( 
        title: Text("Setari"),
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Column(
        children: [ 
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(12),
            ),
            margin: EdgeInsets.only(left: 25, top: 10, right: 25),
            padding: EdgeInsets.all(25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [ 
                //dark mode
                Text(
                  "Dark Mode",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),

                //switch
                CupertinoSwitch(
                  value: Provider.of<ThemeProvider>(context, listen: false).isDarkMode, 
                  onChanged: (value) => Provider.of<ThemeProvider>(context, listen: false).tooggleTheme(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


}
