# SwiftVRChatAPI
A Swift client to interact with the [VRChat API](https://vrchatapi.github.io/).

## Disclaimer

This is the official response of the VRChat Team (from Tupper more specifically) on the usage of the VRChat API.

> Use of the API using applications other than the approved methods (website, VRChat application) are not officially supported. You may use the API for your own application, but keep these guidelines in mind:
> * We do not provide documentation or support for the API.
> * Do not make queries to the API more than once per 60 seconds.
> * Abuse of the API may result in account termination.
> * Access to API endpoints may break at any given time, with no warning.

As stated, this documentation was not created with the help of the official VRChat team. Therefore this documentation is not an official documentation of the VRChat API and may not be always up to date with the latest versions. If you find that a page or endpoint is not longer valid please create an issue and tell us so we can fix it.

## Getting Started

First add the package to your project:
https://developer.apple.com/documentation/xcode/adding-package-dependencies-to-your-app

Below is an example on how to login to the API and fetch your own user information.

```swift
import SwiftVRChatAPI

// Step 1. We begin with creating a client using the username and password.

let client = APIClient(username: "username", password: "password")

// Step 2. VRChat consists of several API's (AuthenticationAPI, WorldAPI, UserAPI, etc...)
// The API functions of the same category is in the corresponding API classes. 
// In the following example, we are using the Authentication API to login with the user credentials.
// To use the API function call, pass in the client and the information needed:

AuthenticationAPI.loginUserInfo(client: client) { user in
    print(user)
}

// Step 3. usually the 2FA email authentication is enabled. Use the verify2FAEmail API function call to complete 2FA:

AuthenticationAPI.verify2FAEmail(client: client, emailOTP: "emailOTP") { verify in
    print(verify)
}

// Step 4. if everything goes well, you should see the user information after calling the loginUserInfo API function again:

AuthenticationAPI.loginUserInfo(client: client) { user in
    print(user)
}
```