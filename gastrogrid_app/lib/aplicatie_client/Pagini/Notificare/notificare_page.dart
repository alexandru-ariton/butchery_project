import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gastrogrid_app/providers/provider_notificari.dart';
import 'package:gastrogrid_app/aplicatie_client/Pagini/Rating/pagina_rating.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, notificationProvider, _) {
          if (notificationProvider.showBanner) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(notificationProvider.notificationMessage),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RatingPage(
                            orderId: notificationProvider.notificationOrderId,
                            userId: FirebaseAuth.instance.currentUser?.uid ?? '',
                          ),
                        ),
                      ).then((_) {
                        // După ce utilizatorul a oferit rating-ul, ascunde notificarea
                        notificationProvider.dismissBanner();
                      });
                    },
                    child: Text('Rate Now'),
                  ),
                  TextButton(
                    onPressed: () {
                      notificationProvider.dismissBanner();
                    },
                    child: Text('Dismiss'),
                  ),
                ],
              ),
            );
          } else {
            return Center(
              child: Text('No notifications'),
            );
          }
        },
      ),
    );
  }
}
