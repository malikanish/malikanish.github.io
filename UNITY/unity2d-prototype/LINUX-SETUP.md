# 🐧 Linux Setup Guide for Unity CI/CD

## Unity Hub Installation Failed? Here's the Fix

The repository method failed due to network issues. Use the direct download method instead.

---

## Method 1: Direct Download (Recommended for Linux)

### Step 1: Download Unity Hub AppImage

```bash
# Create Unity directory
mkdir -p ~/Unity
cd ~/Unity

# Download Unity Hub AppImage
wget https://public-cdn.cloud.unity3d.com/hub/prod/UnityHub.AppImage

# Make it executable
chmod +x UnityHub.AppImage

# Run Unity Hub
./UnityHub.AppImage
```

### Step 2: Create Desktop Shortcut (Optional)

```bash
# Create .desktop file
cat > ~/.local/share/applications/unityhub.desktop << 'EOF'
[Desktop Entry]
Name=Unity Hub
Comment=Unity Hub
Exec=/home/$USER/Unity/UnityHub.AppImage
Icon=unityhub
Terminal=false
Type=Application
Categories=Development;
EOF

# Make it executable
chmod +x ~/.local/share/applications/unityhub.desktop
```

---

## Method 2: Using Snap (Alternative)

```bash
# Install Unity Hub via Snap
sudo snap install unity-hub --classic

# Run Unity Hub
unity-hub
```

---

## Method 3: Manual Unity Editor Installation (Without Hub)

If Unity Hub doesn't work, you can install Unity Editor directly:

```bash
# Download Unity Editor 2022.1.10f1
wget https://download.unity3d.com/download_unity/b89b3e0b5e5d/UnitySetup-2022.1.10f1

# Make executable
chmod +x UnitySetup-2022.1.10f1

# Install (follow prompts)
./UnitySetup-2022.1.10f1
```

---

## After Unity Hub Installation

### 1. Sign In to Unity Hub
- Open Unity Hub
- Click "Sign In"
- Use your Unity account credentials

### 2. Install Unity Editor 2022.1.10f1

```bash
# If using AppImage
./UnityHub.AppImage

# If using Snap
unity-hub
```

In Unity Hub:
1. Go to "Installs" tab
2. Click "Install Editor"
3. Select version: **2022.1.10f1**
4. Add modules:
   - ✅ Android Build Support
   - ✅ Android SDK & NDK Tools
   - ✅ OpenJDK
5. Click "Install"
6. Wait for installation (takes 15-30 minutes)

---

## Alternative: You Don't Need Unity Installed Locally!

**Good News**: For CI/CD pipeline, you don't actually need Unity installed on your local machine. The GitHub Actions runner will use Unity in the cloud.

### What You Actually Need:

1. ✅ **Unity License File** - Get it using GitHub Actions
2. ✅ **Android Keystore** - Create using Java keytool
3. ✅ **GitHub Secrets** - Configure in GitHub
4. ✅ **Slack Webhook** - Setup in Slack

### Skip Unity Installation and Get License via GitHub Actions

Create this workflow to get your license:

```bash
cd ~/Desktop/UNITY/unity2d-prototype

# Create the workflow file
mkdir -p .github/workflows
cat > .github/workflows/get-activation.yml << 'EOF'
name: Get Unity Activation File
on: workflow_dispatch

jobs:
  activation:
    runs-on: ubuntu-latest
    steps:
      - name: Request Activation File
        uses: game-ci/unity-request-activation-file@v2
        with:
          unityVersion: 2022.1.10f1
      
      - name: Upload Activation File
        uses: actions/upload-artifact@v4
        with:
          name: Unity-Activation-File
          path: Unity_v2022.1.10f1.alf
EOF

# Push to GitHub
git add .github/workflows/get-activation.yml
git commit -m "Add activation workflow"
git push origin main
```

Then:
1. Go to your GitHub repo → Actions tab
2. Click "Get Unity Activation File" workflow
3. Click "Run workflow"
4. Download the `.alf` file from artifacts
5. Go to: https://license.unity3d.com/manual
6. Upload `.alf`, download `.ulf`
7. Use `.ulf` content for `UNITY_LICENSE` secret

---

## Install Java for Android Keystore

You need Java to create the Android keystore:

```bash
# Install OpenJDK
sudo apt update
sudo apt install openjdk-11-jdk -y

# Verify installation
java -version
keytool -help
```

---

## Create Android Keystore

```bash
# Navigate to project directory
cd ~/Desktop/UNITY/unity2d-prototype

# Create keystore
keytool -genkey -v -keystore user.keystore -alias myalias -keyalg RSA -keysize 2048 -validity 10000

# Answer the prompts:
# Keystore password: [Create a strong password]
# Re-enter password: [Same password]
# First and last name: [Your Name]
# Organizational unit: [Your Team]
# Organization: [Your Company]
# City: [Your City]
# State: [Your State]
# Country code: [US/UK/etc]
# Correct? yes
# Key password: [Press Enter to use same password]

# Convert to Base64
base64 user.keystore > keystore.txt

# View the base64 content
cat keystore.txt
```

**Save this information:**
- Keystore Password: _______________
- Key Alias: myalias
- Key Password: _______________
- Base64 content: (from keystore.txt)

---

## Setup Slack Webhook

1. Go to: https://api.slack.com/apps
2. Create New App → From scratch
3. Name: "Unity Build Bot"
4. Choose workspace
5. Incoming Webhooks → Activate
6. Add New Webhook to Workspace
7. Choose channel → Allow
8. Copy webhook URL

---

## Configure GitHub Secrets

```bash
# First, fork or push the repository to YOUR GitHub account
cd ~/Desktop/UNITY/unity2d-prototype

# Check if you have a remote
git remote -v

# If it's pointing to practical-works, you need to create your own repo
# Go to GitHub.com → Create new repository → "unity2d-prototype"

# Update remote to your repository
git remote set-url origin https://github.com/YOUR_USERNAME/unity2d-prototype.git

# Push
git push -u origin main
```

Then add secrets:
1. Go to: `https://github.com/YOUR_USERNAME/unity2d-prototype/settings/secrets/actions`
2. Add these 8 secrets:

| Secret Name | Value |
|------------|-------|
| UNITY_LICENSE | Content from .ulf file |
| UNITY_EMAIL | Your Unity email |
| UNITY_PASSWORD | Your Unity password |
| ANDROID_KEYSTORE | Content from keystore.txt |
| ANDROID_KEYSTORE_PASS | Your keystore password |
| ANDROID_KEY_ALIAS | myalias |
| ANDROID_KEY_ALIAS_PASS | Your key password |
| SLACK_WEBHOOK_URL | Your webhook URL |

---

## Validate Setup

```bash
cd ~/Desktop/UNITY/unity2d-prototype

# Make validation script executable
chmod +x validate-setup.sh

# Run validation
./validate-setup.sh
```

---

## Push and Test Pipeline

```bash
cd ~/Desktop/UNITY/unity2d-prototype

# Add all files
git add .

# Commit
git commit -m "Setup CI/CD pipeline"

# Push to trigger build
git push origin main

# Watch build at:
# https://github.com/YOUR_USERNAME/unity2d-prototype/actions
```

---

## Quick Commands Reference

```bash
# Check Java installation
java -version
keytool -help

# Check Git configuration
git remote -v
git branch

# Test Slack webhook
curl -X POST -H 'Content-type: application/json' \
--data '{"text":"Test from Unity CI/CD"}' \
YOUR_WEBHOOK_URL

# View workflow files
ls -la .github/workflows/

# Check project structure
ls -la Assets/ ProjectSettings/
```

---

## Troubleshooting

### Unity Hub Won't Install
**Solution**: Use GitHub Actions method - you don't need Unity locally!

### Network Issues
**Solution**: Check your internet connection, try using mobile hotspot

### Permission Denied
```bash
# Fix permissions
chmod +x validate-setup.sh
chmod +x UnityHub.AppImage
```

### Git Push Rejected
```bash
# Make sure you're pushing to YOUR repository
git remote set-url origin https://github.com/YOUR_USERNAME/unity2d-prototype.git
git push -u origin main
```

### Keystore Creation Failed
```bash
# Make sure Java is installed
sudo apt install openjdk-11-jdk -y
java -version
```

---

## Summary: Minimum Steps for CI/CD

You can complete the assignment WITHOUT installing Unity locally:

1. ✅ Install Java: `sudo apt install openjdk-11-jdk -y`
2. ✅ Create keystore: `keytool -genkey ...`
3. ✅ Setup Slack webhook
4. ✅ Get Unity license via GitHub Actions workflow
5. ✅ Configure 8 GitHub secrets
6. ✅ Push code to trigger pipeline
7. ✅ Download APK/AAB from GitHub Actions artifacts

**Total time**: 1-2 hours
**Unity installation**: NOT required locally!

---

## Next Steps

1. Create your own GitHub repository
2. Push this code to your repo
3. Follow the steps above to configure secrets
4. Push to main branch
5. Watch the magic happen in GitHub Actions!

---

**Need Help?**
- Check: `CI-CD-SETUP-GUIDE.md` for detailed guide
- Check: `QUICK-START.md` for beginner guide
- Run: `./validate-setup.sh` to check setup
