# Dispatcher

# Android

## local.properties
Create this file in __./android/__

```bash
app.id=io.dispatcher.app
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

# Hive

## Generate type adapters

```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

# Docker

__Install__  
https://docs.docker.com/engine/install/


## Docker Compose

__Install__  
https://docs.docker.com/compose/install/

## Docker Build

```bash
docker-compose build
```

## Run on a physical device

```bash
docker-compose up
```

# VSCode

## Run on a physical device
Press F5