import 'package:flutter/material.dart';

class CourseDetailScreen extends StatelessWidget {
  const CourseDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Course Detail',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Course Info Row
            Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xFFD9D9D9)),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Text('CSE 305', style: TextStyle(fontWeight: FontWeight.bold)),
                    Container(
                      height: 16,
                      width: 1,
                      color: Color(0xFFD9D9D9),
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    const Text('Class B', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xFFD9D9D9)),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16),
                    const SizedBox(width: 8),
                    const Text('Tuesday', style: TextStyle(fontWeight: FontWeight.bold)),
                    Container(
                      height: 16,
                      width: 1,
                      color: Color(0xFFD9D9D9),
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    const Icon(Icons.access_time, size: 16),
                    const SizedBox(width: 4),
                    const Text('07:09 AM'),
                  ],
                ),
              ),
            ],
          ),

            const SizedBox(height: 16),

              // Course Title
              const Text(
                'Computer Architecture & organizations',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cursive',
                ),
              ),
              const SizedBox(height: 16),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 3, // Larger button
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {},
                      child: const Text('Attend',  style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 16), // Space between buttons
                  Expanded(
                    flex: 2, // Smaller button
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.black),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {},
                      child: const Text('Reschedule',style: TextStyle(color: Colors.black)),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Student List
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Student List',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Text(
                    'View All',
                    style: TextStyle(color: Colors.blue, fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 3,
                itemBuilder: (context, index) {
                  return _studentTile('Iqbal Mahamud', '2007093', index == 2);
                },
              ),


              // Active Assignment Section
              const Text(
                'Active Assignment',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity, // Makes the container take the full width
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16), // Reduced vertical padding
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFD9D9D9)), // Border color
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center, // Centers the content horizontally
                  children: [
                    const Text(
                      '🤔',
                      style: TextStyle(fontSize: 32),
                    ),
                    const SizedBox(height: 6), // Reduced height
                    const Text(
                      'Assignment Not Found',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    const Text('You don\'t have active assignment'),
                    const SizedBox(height: 12), // Reduced height
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        side: BorderSide(color: Colors.teal), // Teal border
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 12), // Increased width
                      ),
                      onPressed: () {},
                      child: const Text(
                        '+ Create Assignment',
                        style: TextStyle(color: Colors.teal), // Teal text color
                      ),
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



  Widget _studentTile(String name, String id, bool isPresent) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4), // Adds spacing between items
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFD9D9D9)), // Border color
        borderRadius: BorderRadius.circular(8), // Rounded corners
      ),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.grey,
          child: Icon(Icons.person),
        ),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(id),
        trailing: Icon(
          isPresent ? Icons.check_circle : Icons.error,
          color: isPresent ? Colors.green : Colors.red,
        ),
      ),
    );
  }
}
