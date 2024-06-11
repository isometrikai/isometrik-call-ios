
# ISMCallConfiguration

Before using the ISMCallManager for managing calls in your app, ensure you have configured the app secret and project IDs correctly in the ISMCallConfiguration file. These IDs are essential for authenticating and managing calls through the ISMCallManager.

# PushKit Integration

To enable PushKit for receiving VoIP (Voice over IP) notifications, follow these steps:

1. Add PushKit to your `AppDelegate`:

   - Implement the `PKPushRegistryDelegate` protocol.
   - Register for VoIP push notifications in `didFinishLaunchingWithOptions` by calling `registerPushKit()`.
   
       func registerPushKit(){
        let mainQueue = DispatchQueue.main
        let callRegistry = PKPushRegistry(queue: mainQueue)
            callRegistry.delegate = self
             // Register to receive push notifications
              callRegistry.desiredPushTypes = [PKPushType.voIP]
         }
    
    

2. Implement the necessary delegate methods for handling push notifications:

   - `didUpdate pushCredentials`: Pass the push credentials to the ISMCallManager for registration.
            ISMCallManager.shared.pushRegistry(registry, didUpdate: pushCredentials, for: type)
           
   - `didReceiveIncomingPushWith payload`: Handle incoming push notifications and forward them to the ISMCallManager for processing.
            ISMCallManager.shared.pushRegistry(registry, didReceiveIncomingPushWith: payload, for: .voIP,completion: nil)
             
   - if token is invalidated call below method 
            ISMCallManager.shared.invalidatePushKitAPNSDeviceToken(registry, type: type)

3. Ensure to enable the following capabilities in your project settings:

   - Voice OverIP
   - Background Fetch
   - Remote Notifications
   - Background Processing
   
# MQTT Connection
   
  Initilaise the MQTT Connecton on landing page or home page for a active user seesion. use below method.
  
    ISMMQTTManager.shared.connect(clientId: ISMCallConfiguration.userId!)
   

# Making Calls

To initiate a call using ISMCallManager, use the `createCall(callUser:)` method and pass the user details (such as name, ID, etc.) of the user you want to call.

# Required Libraries

Ensure you have the following libraries added to your project:

- [CocoaMQTT](https://github.com/emqx/CocoaMQTT): For MQTT connectivity, required for real-time communication.
- [Kingfisher](https://github.com/onevcat/Kingfisher): For image downloading and caching, used for displaying user avatars.
- [LiveKit](https://github.com/livekit/client-sdk-swift): For handling real-time audio and video communication.
- [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON): For easy JSON parsing and manipulation.


# Logout

Ensure to invoke the invalidatePushKitAPNSDeviceToken function using shared instance of ISMCallManager on logout to invalidate the pushkit device token.
               ISMCallManager.shared.invalidatePushKitAPNSDeviceToken(registry, type: type)
