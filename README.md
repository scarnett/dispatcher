# Dispatcher

# Android

## local.properties
Create this file in __./android/__

```bash
app.id=io.dispatcher.app
sdk.dir=<path/to/your/android/sdk>
flutter.sdk=<path/to/your/flutter/dsk>
flutter.buildMode=debug
flutter.versionName=1.0.0
flutter.versionCode=1
```

---

## google-services.json
Add the firebase configs to the following locations:

```bash
/android/app/src/development/google-services.json
/android/app/src/production/google-services.json
```

# Firebase

## Admin SDK Config
Add the firebase admin sdk config to the following location:

```bash
/firebase/functions/keys/dispatcher-firebase-adminsdk.json
```

# Development

## Enable the remote dev server
Right now this needs to be turned on in the source code: lib/store.dart#41

---

## Install the remote dev server
```bash
npm install -g remotedev-server
```

---

## Start the remote dev server
```bash
remotedev --port 8000
```

# Docker

## Run on a physical device

```bash
docker-compose up
```

# VSCode

## Run on a physical device
Press F5