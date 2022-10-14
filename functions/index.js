const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();
// const database = admin.firestore();

//the cloud function used to send notifications.
exports.fcm = functions
    //the region specified is europe-west1 as it is the nearest to Italy
    .region('europe-west1')
    .https
    .onCall((data, context) => {
        //the data map contains all the information to use.
        //this information is actually passed as parameter when the function is called on the client
        const username = data.username;
        const title = data.title;
        const token = data.token;
        const receiverId = data.receiverId;
        //the payload is a map which contains the data for the notification
        const payload = {
            token: token,
            notification: {
                title: `${username} ha richiesto la partecipazione a ${title}`,
                body: 'Visualizza le tue richieste',
                },
                //the receiverId is the id of the user who receives the notification
                data: {
                    receiverId: receiverId,
                },
            };
        //this is the method which actually sends the notification with the defined payload    
        admin.messaging().send(payload).then((response) => {
            return {success: true};
        }).catch((error) => {
            return {error: error.code};
        });
      });