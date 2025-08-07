import 'package:flutter/material.dart';

class ClassRoutine extends StatelessWidget {
  final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  ClassRoutine({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Row: Date + Add Reminder
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("7 August", style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
                      SizedBox(height: 4),
                      Text("Today", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28)),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF00695C),
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text("+Add Reminder", style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ],
              ),

              SizedBox(height: 16),

              /// Days Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: days.map((day) {
                  final isSelected = day == 'Wed';
                  return Column(
                    children: [
                      Text(day, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                      if (isSelected)
                        Container(
                          margin: EdgeInsets.only(top: 4),
                          height: 2,
                          width: 20,
                          color: Colors.teal,
                        )
                    ],
                  );
                }).toList(),
              ),

              SizedBox(height: 20),

              /// Time Slots
              Expanded(
                child: ListView(
                  children: [
                    TimeSlotWidget(
                      start: '9:30',
                      end: '10:20',
                      color: Colors.blue.shade200,
                      imagePath: 'assets/atom.png',
                    ),
                    TimeSlotWidget(
                      start: '9:50',
                      end: '11:00',
                      color: Colors.grey.shade400,
                      imagePath: 'assets/atom.png',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TimeSlotWidget extends StatelessWidget {
  final String start;
  final String end;
  final Color color;
  final String imagePath;

  const TimeSlotWidget({
    super.key,
    required this.start,
    required this.end,
    required this.color,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Text(start, style: TextStyle(fontSize: 16)),
            Text(end, style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        SizedBox(width: 10),
        Column(
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.teal, width: 2),
                color: Colors.white,
              ),
            ),
            Container(
              width: 2,
              height: 110,
              color: Colors.teal,
            )
          ],
        ),
        SizedBox(width: 10),
        Expanded(
          child: Container(
            margin: EdgeInsets.only(bottom: 16),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                /// Main card content
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.menu_book, size: 20, color: Colors.white),
                        SizedBox(width: 6),
                        const Text("Data Structure",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white,
                            )),
                        Spacer(),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text("Sec A", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.home, size: 18, color: Colors.white),
                        SizedBox(width: 6),
                        Text("ROOM 301", style: TextStyle(color: Colors.white)),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.shield, size: 18, color: Colors.white),
                        SizedBox(width: 6),
                        Text("CSE 101", style: TextStyle(color: Colors.white)),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.person, size: 18, color: Colors.white),
                        SizedBox(width: 6),
                        Text("Shakhawat Hossain", style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ],
                ),

                /// Atom Image – middle right
                Positioned(
                  right: 0,
                  top: 30,
                  child: Image.asset(
                    imagePath,
                    width: 60,
                    height: 60,
                    fit: BoxFit.contain,
                  ),
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}
