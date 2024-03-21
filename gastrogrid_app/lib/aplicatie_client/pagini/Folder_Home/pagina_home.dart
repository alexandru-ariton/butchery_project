import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';


class PaginaHome extends StatefulWidget {
  @override
  _PaginaHomeState createState() => _PaginaHomeState();
}

class _PaginaHomeState extends State<PaginaHome> {
  String selectedAddress = 'Adaugă adresă';
  final List<String> categorylabel = ['food','vegetable','vegetable','vegetable','vegetable','vegetable','vegetable','vegetable'];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      automaticallyImplyLeading: false,
      title: Padding(
        padding: const EdgeInsets.only(right: 20),
        child: GestureDetector(
          onTap: () {},
          child: Row(
            children: [ 
              Icon(Icons.pin_drop),
              SizedBox(width: 30),
              Text(
                "Selecteaza Adresa",
                style: TextStyle(
                  fontSize: 18
                ),
              ),
            ],
          ),
        ),
      ),  
       actions: [ 
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [ 
            Row(
              children: [ 
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text("AAAAAA"),
                ),
              ],
            ),
          ],
        ),
       ],
      ),

   body: CustomScrollView(
    primary: true,
    slivers: <Widget>[
      SliverAppBar(
        automaticallyImplyLeading: false,
        title: Padding(
        padding: const EdgeInsets.only(right: 20),
        child: TextFormField(

        ),
      ),  
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            tooltip: 'Open shopping cart',
            onPressed: () {
              // handle the press
            },
          ),
        ],
      ),
       SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Container(
                child: Padding(padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                          child: Container(
                            padding: EdgeInsets.all(9),
                            height: 70,
                            transformAlignment: Alignment.bottomCenter,
                            child: TextField(
                             
                              decoration: InputDecoration(
                                hintText: 'Search',
                                hintStyle: TextStyle(),
                                border: OutlineInputBorder(
                                 borderRadius: BorderRadius.all(Radius.circular(15.0)),
                                
                                ),
                                prefixIcon: Icon(Icons.search),
                                filled: true,
                                
                              ),
                              
                            ),
                          ),
                       
                     
                    ),
                   
                    Padding(
                      padding: EdgeInsets.only(left: 15),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 210, 203, 203),
                          borderRadius: BorderRadius.circular(15)
                        ),
                        child: IconButton(onPressed:() {}, icon: Icon(Icons.filter_list_outlined),)
                        ),
                    )
                  ],
                ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(9.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Categorii',
                      style: TextStyle(
                        fontSize: 19,
                      ),
                      ),
                      Container(
                        height: 50,
                        child: Row(children: [

                            Expanded(
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: categorylabel.length,
                                itemBuilder: (context,index){
                                    return Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: ActionChip(label: Text(categorylabel[index])),
                                    );
                            }
                            ),
                            
                            )

                        ],


                        ),
                      )
                    ],
                ),
              ),


                Container(
                        height: 400,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Expanded(
                              child: ListView.builder(
                                scrollDirection: Axis.vertical,
                                itemCount: 15,
                                itemBuilder: (context,index){
                                    return Card(
                                      shape:BeveledRectangleBorder(borderRadius: BorderRadius.circular(15)),
      
      child: ListTile(
        onTap: () {
          
        },
        
        title: Text(""),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           
          
          ],
        ),
        
      ),
    );
                            }
                            ),
                            
                            )

                        ],


                        ),
                      ),




            ],
          ),
        ),
      
    ],
  ),

    );
  }
}