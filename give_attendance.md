


          
I need to examine the chat-server.js file to find the socket event for marking students present and provide the documentation for it.
        
            
toolName: search_codebase
            
status: success
          
query: socket event handler for marking student present or attendance status
          
I found the socket event for marking students present. Let me examine the specific implementation in chat-server.js to provide complete documentation.
        
            
toolName: view_files
            
status: success
          
            
filePath: /Users/iqbalmahamud/classmate_backend/graphql-server/chat-server.js
          
Now let me check the markStudentAbsent event as well to provide complete documentation for both present and absent marking.
        
            
toolName: view_files
            
status: success
          
            
filePath: /Users/iqbalmahamud/classmate_backend/graphql-server/chat-server.js
          
# Socket.IO Documentation: Mark Student Attendance Status

**Yes, it is possible to mark a student's status as present/absent and it immediately changes the status in the database.**

## Overview

The system provides real-time attendance marking functionality through Socket.IO events. When a teacher marks a student as present or absent, the status is immediately updated in the database and all participants in the attendance session are notified in real-time.

## Events for Marking Attendance

### 1. Mark Student Present

**Event:** `markStudentPresent`  
**Direction:** Client → Server  
**Authorization:** Teacher only  
**Database Update:** Immediate

#### Request Data Structure:
```javascript
{
  session_id: "64a1b2c3d4e5f6789012345",
  student_id: "64a1b2c3d4e5f6789012348"
}
```

#### Usage Example:
```javascript
socket.emit('markStudentPresent', {
  session_id: 'your_session_id_here',
  student_id: 'student_id_to_mark_present'
});
```

### 2. Mark Student Absent

**Event:** `markStudentAbsent`  
**Direction:** Client → Server  
**Authorization:** Teacher only  
**Database Update:** Immediate

#### Request Data Structure:
```javascript
{
  session_id: "64a1b2c3d4e5f6789012345",
  student_id: "64a1b2c3d4e5f6789012348"
}
```

#### Usage Example:
```javascript
socket.emit('markStudentAbsent', {
  session_id: 'your_session_id_here',
  student_id: 'student_id_to_mark_absent'
});
```

## Server Response Events

### 1. Attendance Updated (Broadcast)

**Event:** `attendanceUpdated`  
**Direction:** Server → All Session Participants  
**Triggered:** When any student's attendance status is changed

#### Response Data Structure:
```javascript
{
  session_id: "64a1b2c3d4e5f6789012345",
  student_id: "64a1b2c3d4e5f6789012348",
  status: "present", // or "absent"
  attendanceRecord: {
    _id: "64a1b2c3d4e5f6789012349",
    student_id: "64a1b2c3d4e5f6789012348",
    session_id: "64a1b2c3d4e5f6789012345",
    status: "present",
    marked_by: "64a1b2c3d4e5f6789012347",
    marked_at: "2024-01-15T10:15:00.000Z"
  },
  updated_by: "Dr. Smith",
  updated_at: "2024-01-15T10:15:00.000Z"
}
```

### 2. Student Marked Present (Teacher Notification)

**Event:** `studentMarkedPresent`  
**Direction:** Server → Teacher Only  
**Triggered:** When a student is successfully marked present

#### Response Data Structure:
```javascript
{
  session_id: "64a1b2c3d4e5f6789012345",
  student_id: "64a1b2c3d4e5f6789012348",
  attendanceRecord: {
    _id: "64a1b2c3d4e5f6789012349",
    student_id: "64a1b2c3d4e5f6789012348",
    session_id: "64a1b2c3d4e5f6789012345",
    status: "present",
    marked_by: "64a1b2c3d4e5f6789012347",
    marked_at: "2024-01-15T10:15:00.000Z"
  }
}
```

### 3. Student Marked Absent (Teacher Notification)

**Event:** `studentMarkedAbsent`  
**Direction:** Server → Teacher Only  
**Triggered:** When a student is successfully marked absent

#### Response Data Structure:
```javascript
{
  session_id: "64a1b2c3d4e5f6789012345",
  student_id: "64a1b2c3d4e5f6789012348",
  attendanceRecord: {
    _id: "64a1b2c3d4e5f6789012349",
    student_id: "64a1b2c3d4e5f6789012348",
    session_id: "64a1b2c3d4e5f6789012345",
    status: "absent",
    marked_by: "64a1b2c3d4e5f6789012347",
    marked_at: "2024-01-15T10:15:00.000Z"
  }
}
```

### 4. Error Handling

**Event:** `attendanceError`  
**Direction:** Server → Client  
**Triggered:** When an error occurs during attendance marking

#### Error Response Data Structure:
```javascript
{
  message: "Error description here"
}
```

## Complete Implementation Example

```javascript
// Initialize socket connection
const socket = io('http://localhost:4002', {
  auth: { token: 'your_jwt_token' }
});

// Mark student present
function markStudentPresent(sessionId, studentId) {
  socket.emit('markStudentPresent', {
    session_id: sessionId,
    student_id: studentId
  });
}

// Mark student absent
function markStudentAbsent(sessionId, studentId) {
  socket.emit('markStudentAbsent', {
    session_id: sessionId,
    student_id: studentId
  });
}

// Listen for real-time updates
socket.on('attendanceUpdated', (data) => {
  console.log(`Student ${data.student_id} marked as ${data.status}`);
  // Update UI immediately
  updateStudentStatusInUI(data.student_id, data.status);
});

// Listen for teacher confirmations
socket.on('studentMarkedPresent', (data) => {
  console.log('Student successfully marked present:', data.attendanceRecord);
});

socket.on('studentMarkedAbsent', (data) => {
  console.log('Student successfully marked absent:', data.attendanceRecord);
});

// Handle errors
socket.on('attendanceError', (error) => {
  console.error('Attendance error:', error.message);
  alert(`Error: ${error.message}`);
});
```

## Key Features

✅ **Immediate Database Update**: Status changes are saved to the database instantly  
✅ **Real-time Notifications**: All session participants receive immediate updates  
✅ **Teacher Authorization**: Only teachers can mark attendance  
✅ **Error Handling**: Comprehensive error reporting  
✅ **Audit Trail**: Complete record of who marked attendance and when  
✅ **Broadcast Updates**: All participants see status changes in real-time

## Authorization Requirements

- Must be authenticated with a valid JWT token
- Must have teacher role/permissions
- Must be the teacher of the active attendance session

The system ensures that attendance status changes are immediately reflected in both the database and all connected clients, providing a seamless real-time experience similar to messaging applications.
        