const functions = require('firebase-functions')
const admin = require('firebase-admin')
const { ref } = require('firebase-functions/lib/providers/database')
admin.initializeApp()

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

exports.onCreateFollower = functions.firestore
  .document('/followers/{userId}/userFollowers/{followerId}')
  .onCreate(async (snapshot, context) => {
    console.log('follower created ', snapshot.id)
    const userId = context.params.userId
    const followerId = context.params.followerId

    const followedUserPostsRef = admin
      .firestore()
      .collection('posts')
      .doc(userId)
      .collection('userPosts')

    const timelinePostsRef = admin
      .firestore()
      .collection('timeline')
      .doc(followerId)
      .collection('timelinePosts')

    const querySnapshot = await followedUserPostsRef.get()

    querySnapshot.forEach(doc => {
      if (doc.exists) {
        const postId = doc.id
        const postData = doc.data()
        timelinePostsRef.doc(postId).set(postData)
      }
    })
  })

exports.onDeleteFollower = functions.firestore
  .document('/followers/{userId}/userFollowers/{followerId}')
  .onDelete(async (snapshot, context) => {
    console.log('follower deleted', snapshot.id)

    const userId = context.params.userId
    const followerId = context.params.followerId

    const timelinePostsRef = admin
      .firestore()
      .collection('timeline')
      .doc(followerId)
      .collection('timelinePosts')
      .where('ownerId', '==', userId)

    const querySnapshot = await timelinePostsRef.get()

    querySnapshot.forEach(doc => {
      if (doc.exists) {
        doc.ref.delete()
      }
    })
  })

// exports.onCreatePost = functions.firestore
//   .document('/posts/{userId}/userPosts/{postId}')
//   .onCreate(async (snapshot, context) => {
//     const postCreated = snapshot.data()
//     const userId = context.params.userId
//     const postId = context.params.postId

//     const userFollowersRef = admin
//       .firestore()
//       .collection('followers')
//       .doc(userId)
//       .collection('userFollowers')

//     const querySnapshot = await userFollowersRef.get()

//     querySnapshot.forEach(doc => {
//       const followerId = doc.id

//       admin
//         .firestore()
//         .collection('timeline')
//         .doc(followerId)
//         .collection('timelinePosts')
//         .doc(postId)
//         .set(postCreated)
//     })
//   })

exports.onUpdatePost = functions.firestore
  .document('/posts/{userId}/userPosts/{postId}')
  .onUpdate(async (change, context) => {
    const postUpdated = change.after.data()

    const userId = context.params.userId
    const postId = context.params.postId

    const userFollowersRef = admin
      .firestore()
      .collection('followers')
      .doc(userId)
      .collection('userFollowers')

    const querySnapshot = await userFollowersRef.get()

    querySnapshot.forEach(doc => {
      const followerId = doc.id

      admin
        .firestore()
        .collection('timeline')
        .doc(followerId)
        .collection('timelinePosts')
        .doc(postId)
        .get()
        .then(doc => {
          if (doc.exists) {
            doc.ref.update(postUpdated)
          }
        })
    })
  })

// exports.onDeletePost = functions.firestore
//   .document('/posts/{userId}/userPosts/{postId}')
//   .onDelete(async (snapshot, context) => {
//     const userId = context.params.userId
//     const postId = context.params.postId

//     const userFollowersRef = admin
//       .firestore()
//       .collection('followers')
//       .doc(userId)
//       .collection('userFollowers')

//     const querySnapshot = await userFollowersRef.get()

//     querySnapshot.forEach(doc => {
//       const followerId = doc.id

//       admin
//         .firestore()
//         .collection('timeline')
//         .doc(followerId)
//         .collection('timelinePosts')
//         .doc(postId)
//         .get()
//         .then(doc => {
//           if (doc.exists) {
//             doc.ref.delete()
//           }
//         })
//     })
//   })

exports.onAddNewComment = functions.firestore
  .document('/comments/{postId}/comments/{commentId}')
  .onCreate(async (snapshot, context) => {
    const postId = context.params.postId
    const commentId = context.params.commentId

    const userFollowersRef = admin
      .firestore()
      .collection('followers')
      .doc(userId)
      .collection('userFollowers')

    const querySnapshot = await userFollowersRef.get()

    querySnapshot.forEach(doc => {
      const followerId = doc.id

      admin
        .firestore()
        .collection('timeline')
        .doc(followerId)
        .collection('timelinePosts')
        .doc(postId)
        .get()
        .then(doc => {
          if (doc.exists) {
            doc.ref.delete()
          }
        })
    })
  })

exports.onCreateNewPost = functions.firestore
   .document('/posts/{userId}/userPosts/{postId}')
   .onCreate(async (snapshot, context) => {
    const userId = context.params.userId
    const userRef = admin.firestore().doc(`users/${userId}`)

    const doc = await userRef.get()

    const androidNotificationToken = doc.data().androidNotificationToken

    if (androidNotificationToken) {
      //send notif
      sendNotifıcatıon(androidNotificationToken)
    } else {
      console.log('no token')
    }

    function sendNotifıcatıon (androidNotificationToken) {
      let body = `Post uploaded. Refresh page now.`

      //create message for push notif
      const message = {
        notification: { body },
        token: androidNotificationToken,
        data: { recipient: userId }
      }

      //send message
      admin
        .messaging()
        .send(message)
        .then(response => {
          console.log('success', response)
        })
        .catch(error => {
          console.log('error', error)
        })
      }
    })

exports.onDeletePost = functions.firestore
   .document('/posts/{userId}/userPosts/{postId}')
   .onDelete(async (snapshot, context) => {
    const userId = context.params.userId
    const userRef = admin.firestore().doc(`users/${userId}`)

    const doc = await userRef.get()

    const androidNotificationToken = doc.data().androidNotificationToken

    if (androidNotificationToken) {
      //send notif
      sendNotifıcatıon(androidNotificationToken)
    } else {
      console.log('no token')
    }

    function sendNotifıcatıon (androidNotificationToken) {
      let body = `Post deleted. Refresh page now.`

      //create message for push notif
      const message = {
        notification: { body },
        token: androidNotificationToken,
        data: { recipient: userId }
      }

      //send message
      admin
        .messaging()
        .send(message)
        .then(response => {
          console.log('success', response)
        })
        .catch(error => {
          console.log('error', error)
        })
    }
  })

exports.onCreateActivityFeedItem = functions.firestore
  .document('/feed/{userId}/feedItems/{activityFeedItem}')
  .onCreate(async (snapshot, context) => {
    const userId = context.params.userId
    const userRef = admin.firestore().doc(`users/${userId}`)

    const doc = await userRef.get()

    const androidNotificationToken = doc.data().androidNotificationToken

    const createdActivityFeedItem = snapshot.data();
    const postId = createdActivityFeedItem.postId
    const id = createdActivityFeedItem.userId

    const ref1 = admin.firestore().doc(`users/${id}`)
    const doc1 = await ref1.get()
    const name = doc1.data().displayName

    if (androidNotificationToken) {
      //send notif
      sendNotifıcatıon(androidNotificationToken, createdActivityFeedItem)
    } else {
      console.log('no token')
    }

    function sendNotifıcatıon (androidNotificationToken, activityFeedItem) {
      let body

      //switch body value based off of notif type
      switch (activityFeedItem.type) {
        case 'comment':
          body = `${name} commented: "${activityFeedItem.commentData}" on your post`
          break
        case 'like':
          body = `${name} liked your post`
          break
        case 'follow':
          body = `${name} started following you`
          break
        default:
          break
      }

      //create message for push notif
      const message = {
        notification: { body },
        token: androidNotificationToken,
        data: { recipient: userId , postId: postId}
      }

      //send message
      admin
        .messaging()
        .send(message)
        .then(response => {
          console.log('success', response)
        })
        .catch(error => {
          console.log('error', error)
        })
    }
  })
