# Creation of a session

## 1. Description

- **Method :** `POST`
- **URL :** `/sessions`

### 1.1. Limitations

This service can only be accessed from a gateway, and with a premium application

## 2. Parameters

### 2.1. Querystring parameters

#### 2.1.1. Mandatory parameters

- __REQUIRED__ `token` the API key of the application creating the session, it **MUST** be a premium application for the session to be created.
- __REQUIRED__ `username` the nickname of the user for which create the session.
- __REQUIRED__ `password` the password of the user

#### 2.1.2. Optional additional parameters

- __OPTIONAL__ `expiration` the duration of the session, in seconds, default is 3600 (an hour).

## 3. Responses

### 3.1. Success response

- **Status :** 201
- **Body :** A JSON Body with the following structure :
  - __token :__ the value of the created token, used to further access the API
  - __expiration :__ the time in seconds after which the session won't be valid anymore, it's either the value specified in parameters, or the default one.

### 3.2. Error responses

#### 3.2.1. Bad request

- **Status :** 400
- **Body :** `{"message": "bad_request"}`
- **Meaning :** You didn't send a required parameter (see section 2.1.1. to know the required parameters for this route)

#### 3.2.2. Gateway not found

- **Status :** 404
- **Body :** `{"message": "gateway_not_found"}`
- **Meaning :** You sent an API key that is unknown in our data. Either check your API key for mispelling or contact us for more informations.

#### 3.2.3. Account not found

- **Status :** 404
- **Body :** `{"message": "account_not_found"}`
- **Meaning :** You sent a username that is unknown in our data. Either check your username for mispelling or contact us for more informations.

#### 3.2.3. Application not found

- **Status :** 404
- **Body :** `{"message": "application_not_found"}`
- **Meaning :** You sent an application key not belonging to any application we know. Check the spelling of the application key

#### 3.2.4. Application not authorized

- **Status :** 401
- **Body :** `{"message": "application_not_authorized"}`
- **Meaning :** You sent an API key belonging to an API that can't create sessions, change the API key you're sending, or don't query this route if you're not authorized.

#### 3.2.5. Password not matching

- **Status :** 403
- **Body :** `{"message": "wrong_password"}`
- **Meaning :** You sent the wrong password for the given username. Check the spelling of your password or ask another password from the user.