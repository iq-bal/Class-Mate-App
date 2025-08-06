# Notification System Frontend Implementation Guide

This guide explains how to implement the notification system on the frontend to display stored notifications from the database.

## Overview

The notification system stores all notifications in the database, allowing users to view them later even if they missed the real-time FCM notification. This provides a persistent notification history and ensures no important updates are lost.

## GraphQL Schema

### Types

```graphql
type Notification {
  _id: ID!
  title: String!
  body: String!
  type: NotificationType!
  recipient_id: User!
  sender_id: User
  related_entity_id: String
  related_entity_type: RelatedEntityType
  data: JSON
  is_read: Boolean!
  read_at: DateTime
  click_action: String
  priority: NotificationPriority!
  fcm_sent: Boolean!
  fcm_sent_at: DateTime
  created_at: DateTime!
  updated_at: DateTime!
}

type PaginatedNotifications {
  notifications: [Notification!]!
  total: Int!
  page: Int!
  limit: Int!
  totalPages: Int!
  hasNextPage: Boolean!
  hasPrevPage: Boolean!
}

type NotificationStats {
  total: Int!
  unread: Int!
  read: Int!
  byType: [NotificationTypeCount!]!
}

enum NotificationType {
  task_assigned
  task_updated
  task_due_reminder
  course_reschedule
  assignment_graded
  class_cancelled
  announcement
  system_update
}

enum NotificationPriority {
  low
  normal
  high
  urgent
}
```

### Queries

```graphql
type Query {
  # Get paginated notifications for current user
  getNotifications(
    page: Int = 1
    limit: Int = 20
    filter: NotificationFilterInput
  ): PaginatedNotifications!
  
  # Get notification statistics
  getNotificationStats: NotificationStats!
  
  # Get unread notification count
  getUnreadNotificationCount: Int!
  
  # Get specific notification by ID
  getNotification(id: ID!): Notification
}
```

### Mutations

```graphql
type Mutation {
  # Mark single notification as read
  markNotificationAsRead(id: ID!): Notification!
  
  # Mark multiple notifications as read
  markNotificationsAsRead(ids: [ID!]!): [Notification!]!
  
  # Mark all notifications as read
  markAllNotificationsAsRead: Int!
  
  # Delete notification
  deleteNotification(id: ID!): Boolean!
  
  # Delete all read notifications
  deleteAllReadNotifications: Int!
}
```

## Frontend Implementation

### 1. Notification List Component

```jsx
import React, { useState, useEffect } from 'react';
import { useQuery, useMutation } from '@apollo/client';
import { GET_NOTIFICATIONS, MARK_NOTIFICATION_AS_READ } from '../graphql/notifications';

const NotificationList = () => {
  const [page, setPage] = useState(1);
  const [filter, setFilter] = useState({});
  
  const { data, loading, error, refetch } = useQuery(GET_NOTIFICATIONS, {
    variables: { page, limit: 20, filter },
    fetchPolicy: 'cache-and-network'
  });
  
  const [markAsRead] = useMutation(MARK_NOTIFICATION_AS_READ, {
    onCompleted: () => refetch()
  });
  
  const handleNotificationClick = async (notification) => {
    if (!notification.is_read) {
      await markAsRead({ variables: { id: notification._id } });
    }
    
    // Handle click action based on notification type
    handleClickAction(notification);
  };
  
  const handleClickAction = (notification) => {
    switch (notification.click_action) {
      case 'TASK_DETAIL':
        // Navigate to task detail page
        navigate(`/tasks/${notification.data.taskId}`);
        break;
      case 'COURSE_SCHEDULE_UPDATE':
        // Navigate to course schedule
        navigate(`/courses/${notification.data.courseId}/schedule`);
        break;
      case 'ASSIGNMENT_DETAIL':
        // Navigate to assignment
        navigate(`/assignments/${notification.data.assignmentId}`);
        break;
      default:
        // Default action or no action
        break;
    }
  };
  
  if (loading) return <div>Loading notifications...</div>;
  if (error) return <div>Error loading notifications</div>;
  
  return (
    <div className="notification-list">
      <div className="notification-header">
        <h2>Notifications</h2>
        <NotificationFilters filter={filter} setFilter={setFilter} />
      </div>
      
      {data?.getNotifications?.notifications.map(notification => (
        <NotificationItem
          key={notification._id}
          notification={notification}
          onClick={() => handleNotificationClick(notification)}
        />
      ))}
      
      <Pagination
        currentPage={page}
        totalPages={data?.getNotifications?.totalPages || 1}
        onPageChange={setPage}
      />
    </div>
  );
};
```

### 2. Notification Item Component

```jsx
const NotificationItem = ({ notification, onClick }) => {
  const getNotificationIcon = (type) => {
    switch (type) {
      case 'task_assigned':
      case 'task_updated':
        return '📋';
      case 'course_reschedule':
        return '📅';
      case 'assignment_graded':
        return '📝';
      case 'class_cancelled':
        return '❌';
      case 'announcement':
        return '📢';
      default:
        return '🔔';
    }
  };
  
  const formatTimeAgo = (timestamp) => {
    // Implement time ago formatting
    return new Date(timestamp).toLocaleDateString();
  };
  
  return (
    <div 
      className={`notification-item ${
        notification.is_read ? 'read' : 'unread'
      } priority-${notification.priority}`}
      onClick={onClick}
    >
      <div className="notification-icon">
        {getNotificationIcon(notification.type)}
      </div>
      
      <div className="notification-content">
        <div className="notification-title">{notification.title}</div>
        <div className="notification-body">{notification.body}</div>
        <div className="notification-meta">
          <span className="notification-time">
            {formatTimeAgo(notification.created_at)}
          </span>
          {notification.sender_id && (
            <span className="notification-sender">
              From: {notification.sender_id.name}
            </span>
          )}
        </div>
      </div>
      
      {!notification.is_read && (
        <div className="unread-indicator"></div>
      )}
    </div>
  );
};
```

### 3. Notification Badge Component

```jsx
const NotificationBadge = () => {
  const { data } = useQuery(GET_UNREAD_COUNT, {
    pollInterval: 30000 // Poll every 30 seconds
  });
  
  const unreadCount = data?.getUnreadNotificationCount || 0;
  
  if (unreadCount === 0) return null;
  
  return (
    <span className="notification-badge">
      {unreadCount > 99 ? '99+' : unreadCount}
    </span>
  );
};
```

### 4. GraphQL Queries and Mutations

```javascript
import { gql } from '@apollo/client';

export const GET_NOTIFICATIONS = gql`
  query GetNotifications($page: Int, $limit: Int, $filter: NotificationFilterInput) {
    getNotifications(page: $page, limit: $limit, filter: $filter) {
      notifications {
        _id
        title
        body
        type
        recipient_id {
          _id
          name
        }
        sender_id {
          _id
          name
        }
        related_entity_id
        related_entity_type
        data
        is_read
        read_at
        click_action
        priority
        created_at
        updated_at
      }
      total
      page
      limit
      totalPages
      hasNextPage
      hasPrevPage
    }
  }
`;

export const GET_UNREAD_COUNT = gql`
  query GetUnreadNotificationCount {
    getUnreadNotificationCount
  }
`;

export const GET_NOTIFICATION_STATS = gql`
  query GetNotificationStats {
    getNotificationStats {
      total
      unread
      read
      byType {
        type
        count
      }
    }
  }
`;

export const MARK_NOTIFICATION_AS_READ = gql`
  mutation MarkNotificationAsRead($id: ID!) {
    markNotificationAsRead(id: $id) {
      _id
      is_read
      read_at
    }
  }
`;

export const MARK_ALL_AS_READ = gql`
  mutation MarkAllNotificationsAsRead {
    markAllNotificationsAsRead
  }
`;

export const DELETE_NOTIFICATION = gql`
  mutation DeleteNotification($id: ID!) {
    deleteNotification(id: $id)
  }
`;
```

### 5. Notification Filters Component

```jsx
const NotificationFilters = ({ filter, setFilter }) => {
  const notificationTypes = [
    'task_assigned',
    'task_updated', 
    'course_reschedule',
    'assignment_graded',
    'class_cancelled',
    'announcement'
  ];
  
  return (
    <div className="notification-filters">
      <select 
        value={filter.type || ''}
        onChange={(e) => setFilter({...filter, type: e.target.value || undefined})}
      >
        <option value="">All Types</option>
        {notificationTypes.map(type => (
          <option key={type} value={type}>
            {type.replace('_', ' ').toUpperCase()}
          </option>
        ))}
      </select>
      
      <select
        value={filter.is_read?.toString() || ''}
        onChange={(e) => setFilter({
          ...filter, 
          is_read: e.target.value ? e.target.value === 'true' : undefined
        })}
      >
        <option value="">All</option>
        <option value="false">Unread</option>
        <option value="true">Read</option>
      </select>
      
      <select
        value={filter.priority || ''}
        onChange={(e) => setFilter({...filter, priority: e.target.value || undefined})}
      >
        <option value="">All Priorities</option>
        <option value="urgent">Urgent</option>
        <option value="high">High</option>
        <option value="normal">Normal</option>
        <option value="low">Low</option>
      </select>
    </div>
  );
};
```

### 6. Real-time Updates with Subscriptions (Optional)

If you want real-time updates, you can implement GraphQL subscriptions:

```javascript
export const NOTIFICATION_SUBSCRIPTION = gql`
  subscription OnNotificationReceived($userId: ID!) {
    notificationReceived(userId: $userId) {
      _id
      title
      body
      type
      is_read
      created_at
    }
  }
`;

// In your component
const { data: subscriptionData } = useSubscription(NOTIFICATION_SUBSCRIPTION, {
  variables: { userId: currentUser.id }
});

useEffect(() => {
  if (subscriptionData?.notificationReceived) {
    // Update notification list or show toast
    refetch();
  }
}, [subscriptionData]);
```

## Styling Examples

### CSS for Notification Components

```css
.notification-list {
  max-width: 600px;
  margin: 0 auto;
}

.notification-item {
  display: flex;
  align-items: flex-start;
  padding: 16px;
  border-bottom: 1px solid #e0e0e0;
  cursor: pointer;
  transition: background-color 0.2s;
}

.notification-item:hover {
  background-color: #f5f5f5;
}

.notification-item.unread {
  background-color: #f0f8ff;
  border-left: 4px solid #2196f3;
}

.notification-item.priority-urgent {
  border-left-color: #f44336;
}

.notification-item.priority-high {
  border-left-color: #ff9800;
}

.notification-icon {
  font-size: 24px;
  margin-right: 12px;
  flex-shrink: 0;
}

.notification-content {
  flex: 1;
}

.notification-title {
  font-weight: 600;
  margin-bottom: 4px;
}

.notification-body {
  color: #666;
  margin-bottom: 8px;
}

.notification-meta {
  display: flex;
  justify-content: space-between;
  font-size: 12px;
  color: #999;
}

.unread-indicator {
  width: 8px;
  height: 8px;
  background-color: #2196f3;
  border-radius: 50%;
  margin-left: 8px;
  flex-shrink: 0;
}

.notification-badge {
  background-color: #f44336;
  color: white;
  border-radius: 10px;
  padding: 2px 6px;
  font-size: 12px;
  font-weight: bold;
  min-width: 18px;
  text-align: center;
}
```

## Best Practices

1. **Pagination**: Always implement pagination for notification lists to handle large numbers of notifications efficiently.

2. **Caching**: Use Apollo Client's caching features to avoid unnecessary network requests.

3. **Real-time Updates**: Consider implementing subscriptions or polling for real-time notification updates.

4. **Accessibility**: Ensure notifications are accessible with proper ARIA labels and keyboard navigation.

5. **Performance**: Use virtual scrolling for very long notification lists.

6. **Offline Support**: Cache notifications locally for offline viewing.

7. **Push Notifications**: Integrate with FCM for browser push notifications when the app is not active.

## Integration with Existing FCM

The database notifications work alongside the existing FCM system:

1. **FCM for Real-time**: FCM delivers immediate notifications when the app is active
2. **Database for Persistence**: All notifications are stored in the database for later viewing
3. **Unified Experience**: Users see both real-time and historical notifications in the same interface

This ensures users never miss important updates, even if they're offline when notifications are sent.