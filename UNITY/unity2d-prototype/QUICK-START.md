# ⚡ Quick Start Guide - CI/CD Pipeline

## 🎯 For Absolute Beginners

This is a simplified, step-by-step guide to get your CI/CD pipeline running.

---

## What You're Building

A system that automatically:
1. Builds your Unity game for Android
2. Creates APK (install file) and AAB (Play Store file)
3. Sends you a Slack message when done
4. Stores the files for download

---

## Prerequisites (Install These First)

### 1. Unity Hub & Unity Editor
```
Download: https://unity.com/download
Install Unity version: 2022.1.10f1
```

### 2. Java JDK (for Android keystore)
```
Windows: https://www.oracle.com/java/technologies/downloads/
Mac: brew install openjdk
Linux: sudo apt-get install openjdk-11-jdk
```

### 3. Git
```
Download: https://git-scm.com/downloads
```

---

## Step 1: Get Unity License (15 minutes)

### Method 1: If You Have Unity Installed

1. Open Unity Hub
2. Sign in with your Unity account
3. Go to Preferences → Licenses
4. Click "Activate New License"
5. Choose "Unity Personal" → "I don't use Unity in a professional capacity"
6. Find license file:
   - **Windows**: `C:\ProgramData\Unity\Unity_lic.ulf`
   - **Mac**: `/Library/Application Support/Unity/Unity_lic.ulf`
   - **Linux**: `~/.local/share/unity3d/Unity/Unity_lic.ulf`
7. Open this file in Notepad/TextEdit
8. Copy ALL content (Ctrl+A, Ctrl+C)
9. Save it somewhere - you'll need it for GitHub Secrets

### Method 2: Using GitHub Actions

1. Create file: `.github/workflows/get-license.yml`
2. Paste this:
```yaml
name: Get Unity License
on: workflow_dispatch
jobs:
  get-license:
    runs-on: ubuntu-latest
    steps:
      - uses: game-ci/unity-request-activation-file@v2
        with:
          unityVersion: 2022.1.10f1
      - uses: actions/upload-artifact@v4
        with:
          name: activation-file
          path: Unity_v2022.1.10f1.alf
```
3. Push to GitHub
4. Go to Actions tab → Run workflow
5. Download the `.alf` file
6. Go to: https://license.unity3d.com/manual
7. Upload `.alf`, download `.ulf`
8. Open `.ulf` in text editor, copy all content

---

## Step 2: Create Android Keystore (10 minutes)

### Open Terminal/Command Prompt

```bash
# Navigate to a folder where you want to save the keystore
cd Desktop

# Run this command (one line)
keytool -genkey -v -keystore user.keystore -alias myalias -keyalg RSA -keysize 2048 -validity 10000
```

### Answer the Questions:

```
Enter keystore password: [Type a password, e.g., "MyKeystore123"]
Re-enter new password: [Type same password]

What is your first and last name? [Your Name]
What is the name of your organizational unit? [Your Team/Company]
What is the name of your organization? [Your Company]
What is the name of your City or Locality? [Your City]
What is the name of your State or Province? [Your State]
What is the two-letter country code for this unit? [US/UK/etc]

Is CN=..., correct? [yes]

Enter key password for <myalias>: [Press Enter to use same password, or type new one]
```

### Save This Information:
```
Keystore Password: _______________
Key Alias: myalias
Key Password: _______________
```

### Convert Keystore to Base64:

**Windows (PowerShell):**
```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("user.keystore")) | Out-File keystore.txt
```

**Mac/Linux:**
```bash
base64 user.keystore > keystore.txt
```

Now you have `keystore.txt` with encoded content.

---

## Step 3: Setup Slack Webhook (5 minutes)

1. Go to: https://api.slack.com/apps
2. Click "Create New App" → "From scratch"
3. App Name: `Unity Build Bot`
4. Choose your workspace → "Create App"
5. Click "Incoming Webhooks" in left sidebar
6. Toggle "Activate Incoming Webhooks" to **ON**
7. Click "Add New Webhook to Workspace"
8. Choose a channel (e.g., #general) → "Allow"
9. Copy the Webhook URL (looks like: `https://hooks.slack.com/services/...`)

---

## Step 4: Add Secrets to GitHub (10 minutes)

1. Go to your GitHub repository
2. Click "Settings" tab
3. Click "Secrets and variables" → "Actions"
4. Click "New repository secret"

### Add These 8 Secrets:

| Name | Where to Get Value |
|------|-------------------|
| `UNITY_LICENSE` | Content from Unity_lic.ulf file (Step 1) |
| `UNITY_EMAIL` | Your Unity account email |
| `UNITY_PASSWORD` | Your Unity account password |
| `ANDROID_KEYSTORE` | Content from keystore.txt file (Step 2) |
| `ANDROID_KEYSTORE_PASS` | Keystore password from Step 2 |
| `ANDROID_KEY_ALIAS` | `myalias` (or what you used) |
| `ANDROID_KEY_ALIAS_PASS` | Key password from Step 2 |
| `SLACK_WEBHOOK_URL` | Webhook URL from Step 3 |

**For each secret:**
1. Click "New repository secret"
2. Type the Name
3. Paste the Value
4. Click "Add secret"

---

## Step 5: Configure Unity Project (15 minutes)

1. Open your Unity project in Unity Hub
2. Go to: **File → Build Settings**
3. Select **Android** → Click **Switch Platform** (wait for it to finish)
4. Click **Player Settings**
5. Set these values:

### Company & Product:
```
Company Name: YourCompany
Product Name: Unity2D Prototype
```

### Identification:
```
Package Name: com.yourcompany.unity2dprototype
Version: 1.0.0
Bundle Version Code: 1
```

### Other Settings → Identification:
```
Minimum API Level: Android 5.0 'Lollipop' (API level 21)
Target API Level: Automatic (highest installed)
```

6. **File → Save Project**
7. Close Unity

---

## Step 6: Push Workflow to GitHub (5 minutes)

The workflow file is already created. Just push it:

```bash
cd unity2d-prototype
git add .
git commit -m "Add CI/CD pipeline"
git push origin main
```

---

## Step 7: Watch It Build! (30 minutes)

1. Go to your GitHub repository
2. Click "Actions" tab
3. You should see a workflow running
4. Click on it to watch progress
5. Wait for it to complete (green checkmark)
6. Check your Slack for notification!

---

## Step 8: Download Your Build

1. In the completed workflow, scroll down to "Artifacts"
2. Download:
   - `Android-APK-xxxxx.zip` (for testing on device)
   - `Android-AAB-xxxxx.zip` (for Google Play Store)
3. Extract the ZIP files
4. Install APK on Android device to test!

---

## 🎉 You're Done!

Now every time you push to `main` branch, your game will automatically build!

---

## 🔧 Common Issues

### "Unity license error"
- Make sure you copied the ENTIRE .ulf file content
- Check UNITY_EMAIL and UNITY_PASSWORD are correct

### "Keystore error"
- Verify passwords have no extra spaces
- Make sure keystore.txt was created correctly

### "Slack notification not sent"
- Test webhook URL with this command:
```bash
curl -X POST -H 'Content-type: application/json' --data '{"text":"Test"}' YOUR_WEBHOOK_URL
```

### "Build failed"
- Check if Unity project builds locally first
- Look at the error logs in GitHub Actions

---

## 📞 Need Help?

1. Check the detailed guide: `CI-CD-SETUP-GUIDE.md`
2. Look at workflow file: `.github/workflows/android-build.yml`
3. Check GitHub Actions logs for specific errors
4. Search error messages on Google

---

## 🚀 Next Steps

Once working, you can:
- Add iOS builds
- Add automated testing
- Deploy to Google Play automatically
- Add more notification channels

---

**Estimated Total Time**: 1-2 hours
**Difficulty**: Beginner-friendly
**Cost**: Free (for public repositories)
