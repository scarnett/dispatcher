# Setup
```bash
npm install -g firebase-tools
firebase login
firebase use --add
# dispatcher-dev-14ebe -> dispatcher-dev
```

# Admin SDK Config
Add the firebase admin sdk config to the following location:

```bash
/firebase/functions/keys/dispatcher-firebase-adminsdk.json
```

# Tests
```bash
npm test
```

# Install extensions

```bash
firebase ext:install storage-resize-images --project dispatcher-dev
```

# Deploy firebase functions

```bash
firebase deploy --only functions --project dispatcher-dev
```

# Deploy firestore rules

```bash
firebase deploy --only firestore:rules --project dispatcher-dev
```

# Firebase Token

```bash
firebase login:ci
```

# Environment configuration
```bash
firebase functions:config:set graphql.endpoint="..."
firebase functions:config:set hasura.admin.secret="..."
firebase functions:config:set hasura.auth.key="..."
firebase functions:config:set twilio.accountsid="..."
firebase functions:config:set twilio.authtoken="..."
firebase functions:config:set twilio.outbound.phonenumber="..."
```

# View current environment configuration
```bash
firebase functions:config:get
```

# Structure
```
functions/
  db/
    name/
      onWrite.f.ts

    name2/
      onCreate.f.ts

    name3/
      onUpdate.f.ts

    name4/
      onCreate.f.ts
      onUpdate.f.ts
      onDelete.f.ts

  endpoint/
    endpointName.f.ts

  schedule/
    jobName.f.ts

  index.ts
```

# Notes
When you deploy these functions a lib/ folder will be generated that contains the transpiled javascript files that get deployed to firebase.
It is highly recommended to delete this folder if it exists prior to deploying the functions. This will ensure that a clean build is being deployed.