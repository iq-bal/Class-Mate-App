import 'package:classmate/views/class_details_student/class_details_student_view.dart';
import 'package:classmate/views/home/widgets/next_class_card.dart';
import 'package:flutter/material.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section with Border Radius
          Container(
            decoration: BoxDecoration(
              color: Colors.blue[900],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20, // Padding for status bar
              left: 20,
              right: 20,
              bottom: 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row with Greeting Text and Bell Icon Inside a Circle
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hello, Iqbal!",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'Georgia',
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Ready for today classes?",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                            fontFamily: 'Arial',
                          ),
                        ),
                      ],
                    ),

                    // Bell Icon inside a Circle
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.blue[800], // Slightly darker shade of the header
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () {
                          // Handle notification bell press
                          print("Notification bell pressed");
                        },
                        icon: const Icon(
                          Icons.notifications_none, // Bell icon
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Date Selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(7, (index) {
                    final dates = ["12", "13", "14", "16", "17", "18", "19"];
                    final days = ["Mon", "Tue", "Wed", "Fri", "Sat", "Sun", "Mon"];
                    final isSelected = index == 2; // Highlight Wednesday
                    return Column(
                      children: [
                        CircleAvatar(
                          backgroundColor: isSelected ? Colors.green : Colors.white,
                          radius: 18,
                          child: Text(
                            dates[index],
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.blue[900],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          days[index],
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    );
                  }),
                ),
                const SizedBox(height: 16),

                // Current Class
                Container(
                  decoration: BoxDecoration(
                    color: Colors.yellow[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Machine Learning",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Dr. Al-Mahmud",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[900],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        child: const Text(
                          "Join",
                          style: TextStyle(fontSize: 14,color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),


          const SizedBox(height: 16),

          // Body Section
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  sectionHeader("Next Classes", () {}),
                  const SizedBox(height: 12),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: List.generate(3, (index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 0), // Space between cards
                          child: NextClassCard(
                            title: "Advanced Algorithms",
                            teacherName: "Abdul Aziz",
                            timeRange: "9:00 - 10:00 AM",
                            icon: Icons.school, // Any relevant icon
                            onTap: () {
                              // Navigate to ClassDetailStudent with specific props
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ClassDetailsStudent(
                                    courseId: "675c9104b6f24d432eb28707",
                                    day: "Friday",
                                    teacherId: "67700aaf73eeab1f443ac463",
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }),
                    ),
                  ),

                  const SizedBox(height: 16),
                  sectionHeader("Assignment", () {}),
                  const SizedBox(height: 12),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      return assignmentCard();
                    },
                  ),
                  const SizedBox(height: 16),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      "Class Tests",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  classTestCard("Image Processing", true),
                  classTestCard("Natural Language Processing", false),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget sectionHeader(String title, VoidCallback onSeeAll) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          GestureDetector(
            onTap: onSeeAll,
            child: const Text(
              "See all",
              style: TextStyle(
                fontSize: 14,
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }

















  Widget assignmentCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 4,
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Title and Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Calculate Comparison",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black.withOpacity(0.8),
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Handle View Task click
                  print("View Task clicked");
                },
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "View Task",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.blue[800],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Subtitle and Icon Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.assessment_outlined,
                  size: 24,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Accounting",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 14, color: Colors.red),
                      const SizedBox(width: 6),
                      Text(
                        "Due tomorrow",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red.withOpacity(0.8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget classTestCard(String testName, bool isSelected) {
    return GestureDetector(
      onTap: () {
        // Handle onTap event
        print("$testName card tapped");
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green[50] : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.green : Colors.grey.shade300,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Test name
            Text(
              testName,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.green.shade800 : Colors.black87,
              ),
            ),
            // Selection icon
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) => ScaleTransition(
                scale: animation,
                child: child,
              ),
              child: Icon(
                isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                key: ValueKey<bool>(isSelected),
                color: isSelected ? Colors.green : Colors.grey,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
