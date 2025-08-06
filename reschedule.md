# Course Reschedule Notification System

This document describes the implementation of the course reschedule notification system that notifies all approved students when a course schedule is updated by the course creator (teacher).

## Overview

The system provides both push notifications (via Firebase Cloud Messaging) and real-time notifications (via Socket.IO) when a course schedule is modified. Only students with `approved` enrollment status receive notifications.

## Architecture

### Components

1. **Notification Service** (`services/notification.service.js`)
   - Handles Firebase Cloud Messaging (FCM) push notifications
   - Sends targeted notifications to enrolled students

2. **Socket Service** (`services/socket.service.js`)
   - Manages real-time Socket.IO events
   - Emits course reschedule events to active users

3. **Schedule Service** (`graphql/modules/schedule/schedule.service.js`)
   - Integrates notification and socket services
   - Triggers notifications when schedule is updated

4. **Chat Server** (`chat-server.js`)
   - Socket.IO server integration
   - Real-time communication infrastructure

## Implementation Details

### 1. Notification Service Functions

#### `sendCourseRescheduleNotification(courseId, newSchedule, oldSchedule)`

**Purpose**: Sends FCM push notifications to approved students about course reschedule.

**Parameters**:
- `courseId`: MongoDB ObjectId of the course
- `newSchedule`: Object containing new schedule details
- `oldSchedule`: Object containing previous schedule details (optional)

**Process**:
1. Retrieves approved enrollments for the course
2. Fetches student and user data with FCM tokens
3. Formats notification message based on schedule change type
4. Sends targeted FCM notifications

**Example Usage**:
```javascript
await sendCourseRescheduleNotification(
  courseId,
  {
    day: 'Monday',
    start_time: '10:00',
    end_time: '12:00',
    room_number: 'Room 101',
    section: 'A'
  },
  {
    day: 'Tuesday',
    start_time: '09:00',
    end_time: '11:00',
    room_number: 'Room 102',
    section: 'A'
  }
);
```

### 2. Socket Service Functions

#### `setSocketInstance(io)`
Sets the Socket.IO server instance for the service.

#### `emitCourseRescheduleEvent(courseId, newSchedule, oldSchedule)`
Emits real-time course reschedule events to active users.

#### `updateActiveUserSocket(userId, socketId)`
Updates the mapping of active user sockets.

#### `joinCourseRoom(userId, courseId)` / `leaveCourseRoom(userId, courseId)`
Manages user subscriptions to course-specific Socket.IO rooms.

### 3. Schedule Service Integration

#### `updateSchedule(scheduleId, updateData, teacherId)`

**Enhanced Functionality**:
1. Retrieves original schedule before update
2. Performs schedule update
3. Compares old vs new schedule to detect changes
4. If changes detected:
   - Sends FCM push notifications
   - Emits real-time Socket.IO events
5. Handles notification failures gracefully

**Change Detection**:
The system detects changes in:
- Day of the week
- Start time
- End time
- Room number
- Section

## Socket.IO Events

### Server Events

#### `courseRescheduled`
**Emitted to**: Specific users and course room
**Payload**:
```javascript
{
  courseId: "course_id",
  courseName: "Course Title",
  newSchedule: {
    day: "Monday",
    start_time: "10:00",
    end_time: "12:00",
    room_number: "Room 101",
    section: "A"
  },
  oldSchedule: {
    day: "Tuesday",
    start_time: "09:00",
    end_time: "11:00",
    room_number: "Room 102",
    section: "A"
  },
  timestamp: "2024-01-15T10:30:00Z"
}
```

#### `notification`
**Emitted to**: Specific users
**Payload**:
```javascript
{
  type: "course_reschedule",
  title: "Course Rescheduled",
  message: "Your course has been rescheduled",
  data: {
    courseId: "course_id",
    newSchedule: { /* schedule details */ }
  },
  timestamp: "2024-01-15T10:30:00Z"
}
```

### Client Events

#### `subscribeToCourse`
**Purpose**: Subscribe to course-specific notifications
**Payload**: `{ course_id: "course_id" }`

#### `unsubscribeFromCourse`
**Purpose**: Unsubscribe from course notifications
**Payload**: `{ course_id: "course_id" }`

## Database Dependencies

### Models Used
- **Course**: Course information and title
- **Enrollment**: Student enrollment status
- **Student**: Student profile data
- **User**: User FCM tokens and basic info
- **Schedule**: Course schedule details

### Required Fields
- `User.fcm_token`: Firebase Cloud Messaging token
- `Enrollment.status`: Must be 'approved' for notifications
- `Schedule`: day, start_time, end_time, room_number, section

## Error Handling

### Notification Failures
- FCM notification failures are logged but don't prevent schedule updates
- Socket.IO event failures are logged with error details
- Individual user notification failures don't affect other users

### Graceful Degradation
- If notification service fails, schedule update still proceeds
- If socket service fails, FCM notifications still work
- Missing FCM tokens are handled gracefully

## Security Considerations

### Authorization
- Only course creators (teachers) can reschedule courses
- Students must have approved enrollment status
- Socket.IO connections require JWT authentication

### Data Privacy
- Only necessary schedule information is included in notifications
- FCM tokens are handled securely
- User data access is limited to enrolled students

## Configuration

### Environment Variables
```env
# Firebase Configuration
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_PRIVATE_KEY=your_private_key
FIREBASE_CLIENT_EMAIL=your_client_email

# Socket.IO Configuration
CHAT_PORT=4002
```

### Firebase Setup
1. Initialize Firebase Admin SDK in notification service
2. Ensure FCM is enabled for the project
3. Configure client apps to receive FCM notifications

## How to Change Schedule and Get Notified

### Step 1: Change Course Schedule (Backend)

#### GraphQL Mutation to Update Schedule
```graphql
mutation UpdateSchedule($scheduleId: ID!, $updateData: ScheduleInput!) {
  updateSchedule(scheduleId: $scheduleId, updateData: $updateData) {
    _id
    day
    start_time
    end_time
    room_number
    section
    course_id {
      _id
      title
    }
  }
}
```

#### Example Variables
```json
{
  "scheduleId": "60f7b3b3b3b3b3b3b3b3b3b3",
  "updateData": {
    "day": "Monday",
    "start_time": "10:00",
    "end_time": "12:00",
    "room_number": "Room 101",
    "section": "A"
  }
}
```

#### What Happens When You Update:
1. **Schedule gets updated** in the database
2. **System detects changes** by comparing old vs new schedule
3. **FCM push notifications** are sent to all approved students
4. **Real-time Socket.IO events** are emitted to active users
5. **Notifications include** both old and new schedule details

### Step 2: Receive Notifications (Frontend)

#### A. Setup Socket.IO Connection
```javascript
import io from 'socket.io-client';

// Connect to chat server with JWT token
const socket = io('http://localhost:4002', {
  auth: {
    token: 'your_jwt_token_here'
  }
});

// Handle connection
socket.on('connect', () => {
  console.log('Connected to notification server');
});
```

#### B. Subscribe to Course Notifications
```javascript
// Subscribe to specific course notifications
const subscribeToCourse = (courseId) => {
  socket.emit('subscribeToCourse', { course_id: courseId });
  console.log(`Subscribed to course: ${courseId}`);
};

// Unsubscribe from course notifications
const unsubscribeFromCourse = (courseId) => {
  socket.emit('unsubscribeFromCourse', { course_id: courseId });
  console.log(`Unsubscribed from course: ${courseId}`);
};
```

#### C. Listen for Course Reschedule Events
```javascript
// Listen for course reschedule events
socket.on('courseRescheduled', (data) => {
  console.log('Course rescheduled:', data);
  
  // Extract notification data
  const {
    courseId,
    courseName,
    newSchedule,
    oldSchedule,
    timestamp
  } = data;
  
  // Show notification to user
  showNotification({
    title: 'Course Rescheduled',
    message: `${courseName} has been rescheduled`,
    type: 'info',
    data: {
      oldSchedule,
      newSchedule
    }
  });
  
  // Update UI with new schedule
  updateCourseScheduleInUI(courseId, newSchedule);
});

// Listen for general notifications
socket.on('notification', (data) => {
  if (data.type === 'course_reschedule') {
    console.log('Course reschedule notification:', data);
    
    // Handle course reschedule notification
    displayInAppNotification({
      title: data.title,
      message: data.message,
      courseId: data.data.courseId,
      newSchedule: data.data.newSchedule
    });
  }
});
```

#### D. Handle FCM Push Notifications (Mobile/Web)

**For React/Web Applications:**
```javascript
// Firebase messaging setup
import { getMessaging, onMessage } from 'firebase/messaging';

const messaging = getMessaging();

// Listen for foreground messages
onMessage(messaging, (payload) => {
  console.log('Message received:', payload);
  
  if (payload.data?.type === 'course_reschedule') {
    // Handle course reschedule push notification
    const notificationData = JSON.parse(payload.data.scheduleData || '{}');
    
    showPushNotification({
      title: payload.notification.title,
      body: payload.notification.body,
      data: notificationData
    });
  }
});
```

**For React Native Applications:**
```javascript
// React Native Firebase messaging
import messaging from '@react-native-firebase/messaging';

// Listen for foreground messages
const unsubscribe = messaging().onMessage(async remoteMessage => {
  console.log('FCM Message received:', remoteMessage);
  
  if (remoteMessage.data?.type === 'course_reschedule') {
    // Handle course reschedule notification
    const scheduleData = JSON.parse(remoteMessage.data.scheduleData || '{}');
    
    // Show local notification
    showLocalNotification({
      title: remoteMessage.notification.title,
      body: remoteMessage.notification.body,
      data: scheduleData
    });
  }
});

// Background message handler
messaging().setBackgroundMessageHandler(async remoteMessage => {
  console.log('Message handled in the background!', remoteMessage);
});
```

### Step 3: Complete Frontend Implementation Example

```javascript
class CourseNotificationManager {
  constructor(socket, courseId) {
    this.socket = socket;
    this.courseId = courseId;
    this.setupListeners();
  }
  
  setupListeners() {
    // Subscribe to course when component mounts
    this.socket.emit('subscribeToCourse', { course_id: this.courseId });
    
    // Listen for course reschedule events
    this.socket.on('courseRescheduled', this.handleCourseReschedule.bind(this));
    this.socket.on('notification', this.handleGeneralNotification.bind(this));
  }
  
  handleCourseReschedule(data) {
    const { courseName, newSchedule, oldSchedule } = data;
    
    // Create user-friendly message
    const message = this.formatScheduleChangeMessage(oldSchedule, newSchedule);
    
    // Show notification
    this.showNotification({
      title: `${courseName} Rescheduled`,
      message: message,
      type: 'schedule_change',
      actions: [
        { text: 'View Details', action: () => this.showScheduleDetails(data) },
        { text: 'Dismiss', action: () => this.dismissNotification() }
      ]
    });
    
    // Update local state/UI
    this.updateLocalSchedule(newSchedule);
  }
  
  handleGeneralNotification(data) {
    if (data.type === 'course_reschedule') {
      // Handle as backup notification
      this.showNotification({
        title: data.title,
        message: data.message,
        type: 'info'
      });
    }
  }
  
  formatScheduleChangeMessage(oldSchedule, newSchedule) {
    const changes = [];
    
    if (oldSchedule.day !== newSchedule.day) {
      changes.push(`Day: ${oldSchedule.day} → ${newSchedule.day}`);
    }
    if (oldSchedule.start_time !== newSchedule.start_time) {
      changes.push(`Time: ${oldSchedule.start_time} → ${newSchedule.start_time}`);
    }
    if (oldSchedule.room_number !== newSchedule.room_number) {
      changes.push(`Room: ${oldSchedule.room_number} → ${newSchedule.room_number}`);
    }
    
    return changes.length > 0 ? changes.join(', ') : 'Schedule updated';
  }
  
  showNotification(notification) {
    // Implement your notification display logic
    console.log('Showing notification:', notification);
  }
  
  updateLocalSchedule(newSchedule) {
    // Update your local state/Redux store/context
    console.log('Updating local schedule:', newSchedule);
  }
  
  cleanup() {
    // Unsubscribe when component unmounts
    this.socket.emit('unsubscribeFromCourse', { course_id: this.courseId });
    this.socket.off('courseRescheduled');
    this.socket.off('notification');
  }
}

// Usage in React component
const CourseComponent = ({ courseId }) => {
  const [notificationManager, setNotificationManager] = useState(null);
  
  useEffect(() => {
    const manager = new CourseNotificationManager(socket, courseId);
    setNotificationManager(manager);
    
    return () => {
      manager.cleanup();
    };
  }, [courseId]);
  
  return (
    <div>
      {/* Your course UI */}
    </div>
  );
};
```

### Step 4: Testing the Complete Flow

1. **Setup**: Ensure you have enrolled students in a course
2. **Update Schedule**: Use GraphQL mutation to change schedule
3. **Verify Notifications**: Check that:
   - FCM push notifications are received
   - Socket.IO events are emitted
   - Frontend UI updates correctly
   - Only approved students receive notifications

### Notification Flow Summary

```
Teacher Updates Schedule
         ↓
   GraphQL Mutation
         ↓
  Schedule Service
         ↓
    Change Detection
         ↓
   ┌─────────────────┐
   ↓                 ↓
FCM Push         Socket.IO
Notification      Event
   ↓                 ↓
Mobile/Web       Real-time
Notification     Frontend Update
```

## Testing

### Test Scenarios
1. **Schedule Update**: Verify notifications sent when schedule changes
2. **No Changes**: Ensure no notifications when schedule unchanged
3. **Multiple Students**: Test notifications to multiple enrolled students
4. **Unapproved Enrollments**: Verify unapproved students don't receive notifications
5. **Missing FCM Tokens**: Handle users without FCM tokens gracefully
6. **Socket Disconnection**: Test real-time events with connected/disconnected users

### Manual Testing
1. Create a course with enrolled students
2. Update the course schedule via GraphQL mutation
3. Verify FCM notifications received on student devices
4. Check Socket.IO events in browser console
5. Confirm database schedule update successful

## Monitoring and Logging

### Log Messages
- Course reschedule notification attempts
- FCM token retrieval and sending status
- Socket.IO event emission status
- Error details for failed operations

### Metrics to Monitor
- Notification delivery success rate
- Socket.IO connection stability
- Schedule update frequency
- User engagement with notifications

## Future Enhancements

### Potential Improvements
1. **Notification Preferences**: Allow users to customize notification types
2. **Batch Notifications**: Optimize for courses with many students
3. **Notification History**: Store notification history for audit
4. **Rich Notifications**: Include course images and additional metadata
5. **Email Fallback**: Send email notifications if FCM fails
6. **Notification Analytics**: Track notification open rates and engagement

### Scalability Considerations
- Implement notification queuing for large courses
- Add rate limiting for notification sending
- Consider using Redis for Socket.IO scaling
- Implement notification batching strategies

## Troubleshooting

### Common Issues

1. **Notifications Not Received**
   - Check FCM token validity
   - Verify enrollment status is 'approved'
   - Confirm Firebase configuration

2. **Socket Events Not Working**
   - Verify Socket.IO connection
   - Check user authentication
   - Confirm course subscription

3. **Schedule Update Fails**
   - Verify teacher authorization
   - Check schedule data validation
   - Review database connection

### Debug Steps
1. Check server logs for error messages
2. Verify database records for enrollments
3. Test FCM token validity
4. Confirm Socket.IO connection status
5. Review GraphQL mutation parameters

---

*This documentation covers the complete implementation of the course reschedule notification system. For technical support or questions, refer to the development team.*