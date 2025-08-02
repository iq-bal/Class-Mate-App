# Message Queries & Mutations with Example Responses

---

## 📩 `GetConversation`

**Query:**

```graphql
query GetConversation($withUserId: ID!, $page: Int, $limit: Int) {
  conversation(with_user_id: $withUserId, page: $page, limit: $limit) {
    id
    content
    message_type
    file_url
    file_name
    createdAt
    sender_id {
      id
      name
      profile_picture
    }
    receiver_id {
      id
      name
      profile_picture
    }
    reactions {
      reaction
      user_id {
        id
        name
        profile_picture
      }
      created_at
    }
    reply_to {
      id
      content
      sender_id {
        name
      }
    }
    forwarded
    forwarded_from {
      id
      name
    }
    read
    delivered
    edited
  }
}
```

**Response:**

```json
{
  "data": {
    "conversation": [
      {
        "id": "688e0fb487a636f50bf3ad97",
        "content": "hello boss",
        "message_type": "text",
        "file_url": null,
        "file_name": null,
        "createdAt": "2025-08-02T13:16:36.157Z",
        "sender_id": {
          "id": "688cb6c45e6bcf7912bb3e30",
          "name": "iqbal",
          "profile_picture": "/uploads/1754124143712-profile_picture.jpg"
        },
        "receiver_id": {
          "id": "688cb6c45e6bcf7912bb3e30",
          "name": "iqbal",
          "profile_picture": "/uploads/1754124143712-profile_picture.jpg"
        },
        "reactions": [],
        "reply_to": null,
        "forwarded": false,
        "forwarded_from": null,
        "read": true,
        "delivered": true,
        "edited": false
      }
    ]
  }
}
```

---

## 💬 `GetConversations`

**Query:**

```graphql
query GetConversations {
  conversations {
    total
    conversations {
      with_user {
        id
        name
        profile_picture
      }
      unread_count
      last_message {
        id
        content
        message_type
        createdAt
        sender_id {
          name
        }
      }
    }
  }
}
```

**Response:**

```json
{
  "data": {
    "conversations": {
      "total": 2,
      "conversations": [
        {
          "with_user": {
            "id": "688cb6c45e6bcf7912bb3e30",
            "name": "iqbal",
            "profile_picture": "/uploads/1754124143712-profile_picture.jpg"
          },
          "unread_count": 0,
          "last_message": {
            "id": "688e1a7f87a636f50bf3adeb",
            "content": "see message",
            "message_type": "text",
            "createdAt": "2025-08-02T14:02:39.421Z",
            "sender_id": {
              "name": "iqbal"
            }
          }
        }
      ]
    }
  }
}
```

---

## 📨 `GetUnreadMessages`

**Query:**

```graphql
query GetUnreadMessages {
  unreadMessageCount
  unreadMessages {
    id
    content
    message_type
    createdAt
    sender_id {
      id
      name
      profile_picture
    }
  }
}
```

**Response:**

```json
{
  "data": {
    "unreadMessageCount": 0,
    "unreadMessages": []
  }
}
```

---

## 🔍 `SearchMessages`

**Query:**

```graphql
query SearchMessages($query: String!, $withUserId: ID) {
  searchMessages(query: $query, with_user_id: $withUserId) {
    id
    content
    message_type
    createdAt
    sender_id {
      id
      name
      profile_picture
    }
    receiver_id {
      id
      name
      profile_picture
    }
  }
}
```

**Response:**

```json
{
  "data": {
    "searchMessages": [
      {
        "id": "688e0fb487a636f50bf3ad97",
        "content": "hello boss",
        "message_type": "text",
        "createdAt": "2025-08-02T13:16:36.157Z",
        "sender_id": {
          "id": "688cb6c45e6bcf7912bb3e30",
          "name": "iqbal",
          "profile_picture": "/uploads/1754124143712-profile_picture.jpg"
        },
        "receiver_id": {
          "id": "688cb6c45e6bcf7912bb3e30",
          "name": "iqbal",
          "profile_picture": "/uploads/1754124143712-profile_picture.jpg"
        }
      }
    ]
  }
}
```

---

## 📝 `SendMessage`

**Mutation:**

```graphql
mutation SendMessage($messageInput: MessageInput!) {
  sendMessage(messageInput: $messageInput) {
    id
    content
    message_type
    file_url
    createdAt
    sender_id {
      id
      name
      profile_picture
    }
    receiver_id {
      id
      name
      profile_picture
    }
  }
}
```

**Request Body:**

```json
{
  "messageInput": {
    "receiver_id": "688cb6c45e6bcf7912bb3e30",
    "content": "Your message content",
    "message_type": "text"
  }
}
```

**Response:**

```json
{
  "data": {
    "sendMessage": {
      "id": "688e204a35acaf672bd80ae4",
      "content": "Your message content",
      "message_type": "text",
      "file_url": null,
      "createdAt": "2025-08-02T14:27:22.603Z",
      "sender_id": {
        "id": "688cb6c45e6bcf7912bb3e30",
        "name": "iqbal",
        "profile_picture": "/uploads/1754124143712-profile_picture.jpg"
      },
      "receiver_id": {
        "id": "688cb6c45e6bcf7912bb3e30",
        "name": "iqbal",
        "profile_picture": "/uploads/1754124143712-profile_picture.jpg"
      }
    }
  }
}
```

---

## 📖 `MarkMessagesAsRead`

**Mutation:**

```graphql
mutation MarkMessagesAsRead($withUserId: ID!) {
  markMessagesAsRead(with_user_id: $withUserId)
}
```

**Response:**

```json
{
  "data": {
    "markMessagesAsRead": true
  }
}
```

---

## ✏️ `EditMessage`

**Mutation:**

```graphql
mutation EditMessage($messageId: ID!, $newContent: String!) {
  editMessage(message_id: $messageId, new_content: $newContent) {
    id
    content
    edited
    edited_at
  }
}
```

**Response:**

```json
{
  "data": {
    "editMessage": {
      "id": "688e1f0c35acaf672bd80a93",
      "content": "hello kaamchor",
      "edited": true,
      "edited_at": "2025-08-02T14:24:56.987Z"
    }
  }
}
```

---

## ❌ `DeleteMessage`

**Mutation:**

```graphql
mutation DeleteMessage($messageId: ID!, $forEveryone: Boolean) {
  deleteMessage(message_id: $messageId, for_everyone: $forEveryone)
}
```

**Response:**

```json
{
  "data": {
    "deleteMessage": true
  }
}
```

---

## ❤️ `ReactToMessage`

**Mutation:**

```graphql
mutation ReactToMessage($reactionInput: MessageReactionInput!) {
  reactToMessage(reactionInput: $reactionInput) {
    id
    reactions {
      reaction
      user_id {
        id
        name
        profile_picture
      }
      created_at
    }
  }
}
```

**Request Body:**

```json
{
  "reactionInput": {
    "message_id": "688e1f7135acaf672bd80a99",
    "reaction": "👍"
  }
}
```

**Response:**

```json
{
  "data": {
    "reactToMessage": {
      "id": "688e1f7135acaf672bd80a99",
      "reactions": [
        {
          "reaction": "👍",
          "user_id": {
            "id": "688cb6c45e6bcf7912bb3e30",
            "name": "iqbal",
            "profile_picture": "/uploads/1754124143712-profile_picture.jpg"
          },
          "created_at": "2025-08-02T14:29:26.314Z"
        }
      ]
    }
  }
}
```

---

## 🔁 `ForwardMessage`

**Mutation:**

```graphql
mutation ForwardMessage($messageId: ID!, $toUserIds: [ID!]!) {
  forwardMessage(message_id: $messageId, to_user_ids: $toUserIds) {
    id
    content
    forwarded
    forwarded_from {
      id
      name
    }
    receiver_id {
      id
      name
    }
  }
}
```

**Request Body:**

```json
{
  "messageId": "688e204a35acaf672bd80ae4",
  "toUserIds": ["688cb6c45e6bcf7912bb3e30"]
}
```

**Response:**

```json
{
  "data": {
    "forwardMessage": [
      {
        "id": "688e207435acaf672bd80aeb",
        "content": "Your message content",
        "forwarded": true,
        "forwarded_from": {
          "id": "688cb6c45e6bcf7912bb3e30",
          "name": "iqbal"
        },
        "receiver_id": {
          "id": "688cb6c45e6bcf7912bb3e30",
          "name": "iqbal"
        }
      }
    ]
  }
}
```

