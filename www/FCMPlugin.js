var exec = require('cordova/exec');

function FCMPlugin() { 
	console.log("FCMPlugin.js: is created");
}

// SUBSCRIBE TO TOPIC //
FCMPlugin.prototype.subscribeToTopic = function( topic, success, error ){
	exec(success, error, "FCMPlugin", 'subscribeToTopic', [topic]);
}
// UNSUBSCRIBE FROM TOPIC //
FCMPlugin.prototype.unsubscribeFromTopic = function( topic, success, error ){
	exec(success, error, "FCMPlugin", 'unsubscribeFromTopic', [topic]);
}
// NOTIFICATION CALLBACK //
FCMPlugin.prototype.onNotification = function( callback, success, error ){
	FCMPlugin.prototype.onNotificationReceived = callback;
	exec(success, error, "FCMPlugin", 'registerNotification',[]);
}
// TOKEN REFRESH CALLBACK //
FCMPlugin.prototype.onTokenRefresh = function( callback ){
	FCMPlugin.prototype.onTokenRefreshReceived = callback;
}
// GET TOKEN //
FCMPlugin.prototype.getToken = function( success, error ){
	exec(success, error, "FCMPlugin", 'getToken', []);
}

// REMOVE TOKEN //
FCMPlugin.prototype.removeToken = function(success, error) {
	exec(success, error, 'FCMPlugin', 'removeToken', []);
}

// DEFAULT NOTIFICATION CALLBACK //
FCMPlugin.prototype.onNotificationReceived = function(payload){
	console.log("Received push notification")
	console.log(payload)
}
// DEFAULT TOKEN REFRESH CALLBACK //
FCMPlugin.prototype.onTokenRefreshReceived = function(token){
	console.log("Received token refresh")
	console.log(token)
}

//VOIP

// GET TOKEN //

FCMPlugin.prototype.initVoip = function( success, error ){
	exec(success, error, "FCMPlugin", 'initVoip', []);
}

FCMPlugin.prototype.getVoipToken = function( success, error ){
	exec(success, error, "FCMPlugin", 'getVoipToken', []);
}

// NOTIFICATION CALLBACK //
FCMPlugin.prototype.onVoipNotification = function( callback, success, error ){
	FCMPlugin.prototype.onVoipNotificationReceived = callback;
	//exec(success, error, "FCMPlugin", 'registerNotification',[]);
}

// TOKEN REFRESH CALLBACK //
FCMPlugin.prototype.onVoipTokenRefresh = function( callback ){
	FCMPlugin.prototype.onVoipTokenRefreshReceived = callback;
}

// DEFAULT NOTIFICATION CALLBACK //
FCMPlugin.prototype.onVoipNotificationReceived = function(payload){
	console.log("Received push notification")
	console.log(payload)
}

// DEFAULT TOKEN REFRESH CALLBACK //
FCMPlugin.prototype.onVoipTokenRefreshReceived = function(token){
	console.log("Received token refresh")
	console.log(token)
}

//VOIP

FCMPlugin.prototype.appEnterForeground = function() {
	exec(success, error, "FCMPlugin", 'appEnterForeground', []);
}

FCMPlugin.prototype.appEnterBackground = function() {
	exec(success, error, "FCMPlugin", 'appEnterBackground', []);
}

// FIRE READY //
exec(function(result){ console.log("FCMPlugin Ready OK") }, function(result){ console.log("FCMPlugin Ready ERROR") }, "FCMPlugin",'ready',[]);





var fcmPlugin = new FCMPlugin();
module.exports = fcmPlugin;
