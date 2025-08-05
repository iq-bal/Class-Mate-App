Attendance Socket Server Documentation
This document outlines the Socket.IO server implementation for managing attendance sessions in a real-time application. The server handles attendance-related events, such as starting and joining sessions, marking students as present or absent, retrieving session data, performing bulk updates, and ending sessions. The system is designed for use by teachers and students, with proper authentication and error handling.
Overview
The attendance management system uses Socket.IO for real-time communication between clients (teachers and students) and the server. The server integrates with a MongoDB database via Mongoose and utilizes services for user, teacher, and attendance management. It ensures that only authorized teachers can start, manage, and end attendance sessions, while students can join sessions and have their attendance recorded.
Prerequisites

Node.js: The server is built using Node.js with Express and Socket.IO.
MongoDB: A MongoDB database is used for storing attendance records, user data, and teacher profiles.
Authentication: JSON Web Tokens (JWT) are used to authenticate users connecting to the server.
Dependencies: Ensure the following packages are installed:
socket.io
express
cors
mongoose
jsonwebtoken
dotenv


Environment Variables:
ACCESS_TOKEN_SECRET: Secret key for JWT verification.
CHAT_PORT: Port for the Socket.IO server (defaults to 4002).
MongoDB connection details (configured in connectDB).



Authentication Middleware
The server uses a Socket.IO middleware to authenticate incoming connections:

Token Verification: The middleware extracts the JWT from socket.handshake.auth.token, verifies it using the ACCESS_TOKEN_SECRET, and retrieves the user details using getUserByUID.
User Attachment: The authenticated user’s details are attached to socket.user for use in event handlers.
Error Handling: If no token is provided, the token is invalid, or the user is not found, an error is returned, and the connection is rejected.

Attendance Events
The server handles the following attendance-related Socket.IO events, each with specific inputs, actions, and emitted responses.
1. startAttendanceSession
Purpose: Initiates a new attendance session for a teacher.
Input Parameters:

session_id (String): Unique identifier for the attendance session.

Actions:

Verifies the user’s identity using getUserByUID.
Confirms the user is a teacher using getTeacherByUserId.
Calls startAttendanceSession to create the session in the database.
Stores the session in activeAttendanceSessions with the teacher’s ID, socket ID, and an empty set of students.
Emits the attendanceSessionStarted event to the teacher with session details.

Emitted Events:

Success: attendanceSessionStarted
Payload:
session_id (String): The session ID.
session (Object): Session details from the database.
totalStudents (Number): Number of students in the session.
attendanceRecords (Array): List of attendance records.




Error: attendanceError
Payload:
message (String): Error message (e.g., "Teacher profile not found").





Example:
socket.emit('startAttendanceSession', { session_id: '12345' });

2. joinAttendanceSession
Purpose: Allows a student to join an active attendance session.
Input Parameters:

session_id (String): The ID of the session to join.

Actions:

Checks if the session exists in activeAttendanceSessions.
Adds the student’s ID to the session’s students set.
Joins the student to the Socket.IO room attendance_${session_id}.
Notifies the teacher via studentJoinedAttendance with the student’s details.
Confirms to the student via attendanceSessionJoined.

Emitted Events:

To Teacher: studentJoinedAttendance
Payload:
session_id (String): The session ID.
student_id (String): The student’s ID.
student_name (String): The student’s name.
joined_at (Date): Timestamp of joining.




To Student: attendanceSessionJoined
Payload:
session_id (String): The session ID.
message (String): Success message.




Error: attendanceError
Payload:
message (String): Error message (e.g., "Attendance session not active").





Example:
socket.emit('joinAttendanceSession', { session_id: '12345' });

3. markStudentPresent
Purpose: Allows a teacher to mark a student as present in a session.
Input Parameters:

session_id (String): The session ID.
student_id (String): The ID of the student to mark present.

Actions:

Verifies the user is a teacher using getUserByUID and getTeacherByUserId.
Calls markStudentPresent to update the attendance record in the database.
Notifies all participants in the attendance_${session_id} room via attendanceUpdated.
Confirms to the teacher via studentMarkedPresent.

Emitted Events:

To Room: attendanceUpdated
Payload:
session_id (String): The session ID.
student_id (String): The student’s ID.
status (String): "present".
attendanceRecord (Object): The updated attendance record.
updated_by (String): The teacher’s name.
updated_at (Date): Timestamp of the update.




To Teacher: studentMarkedPresent
Payload:
session_id (String): The session ID.
student_id (String): The student’s ID.
attendanceRecord (Object): The updated record.




Error: attendanceError
Payload:
message (String): Error message (e.g., "Teacher profile not found").





Example:
socket.emit('markStudentPresent', { session_id: '12345', student_id: 'student123' });

4. markStudentAbsent
Purpose: Allows a teacher to mark a student as absent in a session.
Input Parameters:

session_id (String): The session ID.
student_id (String): The ID of the student to mark absent.

Actions:

Verifies the user is a teacher using getUserByUID and getTeacherByUserId.
Calls markStudentAbsent to update the attendance record in the database.
Notifies all participants in the attendance_${session_id} room via attendanceUpdated.
Confirms to the teacher via studentMarkedAbsent.

Emitted Events:

To Room: attendanceUpdated
Payload:
session_id (String): The session ID.
student_id (String): The student’s ID.
status (String): "absent".
attendanceRecord (Object): The updated attendance record.
updated_by (String): The teacher’s name.
updated_at (Date): Timestamp of the update.




To Teacher: studentMarkedAbsent
Payload:
session_id (String): The session ID.
student_id (String): The student’s ID.
attendanceRecord (Object): The updated record.




Error: attendanceError
Payload:
message (String): Error message (e.g., "Teacher profile not found").





Example:
socket.emit('markStudentAbsent', { session_id: '12345', student_id: 'student123' });

5. getAttendanceSessionData
Purpose: Retrieves detailed data for an attendance session.
Input Parameters:

session_id (String): The session ID.

Actions:

Verifies the user is a teacher using getUserByUID and getTeacherByUserId.
Calls getAttendanceSessionData to fetch session details from the database.
Sends the data to the teacher via attendanceSessionData.

Emitted Events:

Success: attendanceSessionData
Payload:
session_id (String): The session ID.
session (Object): Session details.
attendanceRecords (Array): List of attendance records.
statistics (Object): Session statistics (e.g., total students, attendance rate).




Error: attendanceError
Payload:
message (String): Error message (e.g., "Teacher profile not found").





Example:
socket.emit('getAttendanceSessionData', { session_id: '12345' });

6. bulkUpdateAttendance
Purpose: Allows a teacher to update attendance for multiple students in a single request.
Input Parameters:

session_id (String): The session ID.
attendanceUpdates (Array): List of updates, each containing:
student_id (String): The student’s ID.
status (String): "present" or "absent".



Actions:

Verifies the user is a teacher using getUserByUID and getTeacherByUserId.
Calls bulkUpdateAttendance to process the updates in the database.
Notifies all participants in the attendance_${session_id} room via attendanceBulkUpdated.
Confirms to the teacher via attendanceBulkUpdateComplete.

Emitted Events:

To Room: attendanceBulkUpdated
Payload:
session_id (String): The session ID.
updatedRecords (Array): List of updated attendance records.
updated_by (String): The teacher’s name.
updated_at (Date): Timestamp of the update.




To Teacher: attendanceBulkUpdateComplete
Payload:
session_id (String): The session ID.
updatedRecords (Array): List of updated records.
totalUpdated (Number): Number of records updated.




Error: attendanceError
Payload:
message (String): Error message (e.g., "Teacher profile not found").





Example:
socket.emit('bulkUpdateAttendance', {
  session_id: '12345',
  attendanceUpdates: [
    { student_id: 'student123', status: 'present' },
    { student_id: 'student124', status: 'absent' }
  ]
});

7. endAttendanceSession
Purpose: Ends an active attendance session.
Input Parameters:

session_id (String): The session ID.

Actions:

Verifies the session exists in activeAttendanceSessions.
Confirms the user is the session’s teacher using getUserByUID and getTeacherByUserId.
Fetches final session data using getAttendanceSessionData.
Notifies all participants in the attendance_${session_id} room via attendanceSessionEnded.
Removes the session from activeAttendanceSessions.
Confirms to the teacher via attendanceSessionEndedConfirm.

Emitted Events:

To Room: attendanceSessionEnded
Payload:
session_id (String): The session ID.
finalData (Object): Final session data, including records and statistics.
ended_by (String): The teacher’s name.
ended_at (Date): Timestamp of session end.




To Teacher: attendanceSessionEndedConfirm
Payload:
session_id (String): The session ID.
finalData (Object): Final session data.




Error: attendanceError
Payload:
message (String): Error message (e.g., "Only the session teacher can end attendance").





Example:
socket.emit('endAttendanceSession', { session_id: '12345' });

Error Handling

Authentication Errors: Handled by the middleware, emitting an error to the client if the token is missing, invalid, or the user is not found.
Event Errors: Each event handler catches errors and emits an attendanceError event with a descriptive message (e.g., "Teacher profile not found", "Attendance session not active").
Logging: Comprehensive logging is implemented with [SOCKET DEBUG] tags to track events, errors, and data for debugging purposes.

Data Structures

activeAttendanceSessions (Map):
Key: session_id (String)
Value: Object containing:
teacher_id (String): The teacher’s ID.
teacher_socket (String): The teacher’s socket ID.
students (Set): Set of student IDs in the session.
started_at (Date): Timestamp when the session started.





Security Considerations

Authentication: Only authenticated users with valid JWTs can connect.
Authorization: Only teachers can start, manage, and end attendance sessions.
Room-Based Notifications: Updates are broadcast only to participants in the attendance_${session_id} room, ensuring data privacy.
Error Handling: Graceful handling of errors prevents server crashes and provides clear feedback to clients.

Usage Example

Teacher Starts a Session:
socket.emit('startAttendanceSession', { session_id: 'session123' });
socket.on('attendanceSessionStarted', (data) => {
  console.log('Session started:', data);
});


Student Joins a Session:
socket.emit('joinAttendanceSession', { session_id: 'session123' });
socket.on('attendanceSessionJoined', (data) => {
  console.log('Joined session:', data);
});


Teacher Marks Attendance:
socket.emit('markStudentPresent', { session_id: 'session123', student_id: 'student123' });
socket.on('studentMarkedPresent', (data) => {
  console.log('Student marked present:', data);
});


Teacher Ends the Session:
socket.emit('endAttendanceSession', { session_id: 'session123' });
socket.on('attendanceSessionEndedConfirm', (data) => {
  console.log('Session ended:', data);
});



Debugging

The server logs detailed information for each event, including user details, session IDs, and error stacks, prefixed with [SOCKET DEBUG].
Logs include the state of activeAttendanceSessions, the number of students, and emitted event data for troubleshooting.

Limitations

Thumbnail Generation: The code includes a placeholder for thumbnail generation (generateThumbnail), which is not implemented.
File Handling: File uploads for attendance sessions are not currently supported but could be extended.
Scalability: The in-memory activeAttendanceSessions map may need to be replaced with a persistent store (e.g., Redis) for large-scale applications.

Future Enhancements

Add support for real-time attendance statistics updates.
Implement thumbnail generation for uploaded media.
Add timeout mechanisms for inactive attendance sessions.
Integrate with a notification system to alert students of session start/end.

Server Startup
The server starts on the port specified in CHAT_PORT (defaults to 4002) and logs the following:

Server startup confirmation.
WebSocket endpoint URL (ws://localhost:<port>).
Timestamp of server start.

Example Startup Log:
🚀 Chat server running on port 4002
📡 Socket.IO server ready for connections
🔗 WebSocket endpoint: ws://localhost:4002
📊 Server started at: 2025-08-04T13:43:00.000Z
