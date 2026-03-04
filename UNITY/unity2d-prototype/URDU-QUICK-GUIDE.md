# 🚀 CI/CD Pipeline - Quick Guide (Urdu/Roman)

## Aapko Kya Karna Hai (5 Main Steps)

---

## Step 1: Keystore Banao (10 minutes)

```bash
cd ~/Desktop/UNITY/unity2d-prototype

# Keystore create karo
keytool -genkey -v -keystore user.keystore -alias myalias -keyalg RSA -keysize 2048 -validity 10000

# Ye information save karo:
# - Keystore password: _____________
# - Key alias: myalias
# - Key password: _____________

# Base64 mein convert karo
base64 user.keystore > keystore.txt

# Dekho content
cat keystore.txt
```

**Save karo**: keystore.txt ka content (GitHub secret mein use hoga)

---

## Step 2: Slack Webhook Setup (5 minutes)

1. Jao: https://api.slack.com/apps
2. "Create New App" → "From scratch"
3. Name: "Unity Build Bot"
4. Workspace select karo
5. "Incoming Webhooks" → Toggle ON
6. "Add New Webhook to Workspace"
7. Channel select karo (e.g., #general)
8. "Allow" click karo
9. **Webhook URL copy karo** (ye GitHub secret mein jayega)

---

## Step 3: Unity License Lo (15 minutes)

### Method 1: Workflow Se (Recommended)

```bash
cd ~/Desktop/UNITY/unity2d-prototype

# Check karo workflow file hai ya nahi
ls -la .github/workflows/get-activation.yml

# Agar nahi hai, to banao:
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

# Push karo GitHub pe
git add .github/workflows/get-activation.yml
git commit -m "Add activation workflow"
git push origin main
```

**Phir**:
1. Jao: `https://github.com/YOUR_USERNAME/unity2d-prototype/actions`
2. "Get Unity Activation File" workflow pe click karo
3. "Run workflow" button click karo
4. Wait karo (2-3 minutes)
5. Artifact download karo: `Unity-Activation-File.zip`
6. Extract karo → `.alf` file milegi

**License Get Karo**:
1. Jao: https://license.unity3d.com/manual
2. `.alf` file upload karo
3. `.ulf` file download karo
4. `.ulf` file ko text editor mein kholo
5. **POORA content copy karo** (Ctrl+A, Ctrl+C)

---

## Step 4: GitHub Secrets Configure Karo (10 minutes)

Jao: `https://github.com/YOUR_USERNAME/unity2d-prototype/settings/secrets/actions`

**8 Secrets Add Karo**:

| Secret Name | Value Kahan Se Milega |
|------------|---------------------|
| `UNITY_LICENSE` | `.ulf` file ka POORA content |
| `UNITY_EMAIL` | Aapka Unity account email |
| `UNITY_PASSWORD` | Aapka Unity account password |
| `ANDROID_KEYSTORE` | `keystore.txt` ka content (Step 1) |
| `ANDROID_KEYSTORE_PASS` | Keystore password (Step 1) |
| `ANDROID_KEY_ALIAS` | `myalias` |
| `ANDROID_KEY_ALIAS_PASS` | Key password (Step 1) |
| `SLACK_WEBHOOK_URL` | Slack webhook URL (Step 2) |

**Har secret ke liye**:
1. "New repository secret" click karo
2. Name type karo (exactly as shown)
3. Value paste karo
4. "Add secret" click karo

---

## Step 5: Push Karo Aur Build Dekho (30 minutes)

```bash
cd ~/Desktop/UNITY/unity2d-prototype

# Sab files add karo
git add .

# Commit karo
git commit -m "Setup CI/CD pipeline"

# Push karo (build automatically start hoga)
git push origin main
```

**Build Dekho**:
1. Jao: `https://github.com/YOUR_USERNAME/unity2d-prototype/actions`
2. Latest workflow run pe click karo
3. Steps expand karke dekho
4. Wait karo (15-30 minutes)
5. Green checkmark dekho ✅

**Artifacts Download Karo**:
1. Scroll down to "Artifacts" section
2. Download:
   - `Android-APK-xxxxx.zip`
   - `Android-AAB-xxxxx.zip`
3. Extract karo
4. APK ko Android phone pe test karo!

**Slack Check Karo**:
- Aapke Slack channel mein notification aana chahiye
- Build details ke saath

---

## 📸 Screenshot Lo

Build successful hone ke baad:
1. GitHub Actions page ka screenshot lo
2. Dikhna chahiye:
   - ✅ Green checkmark
   - All steps completed
   - Artifacts section
   - Build time
3. Save karo as: `screenshots/successful-build.png`

```bash
mkdir -p screenshots
# Screenshot save karo is folder mein
```

---

## ✅ Final Checklist

- [ ] Keystore banaya aur base64 kiya
- [ ] Slack webhook setup kiya
- [ ] Unity license mila (.ulf file)
- [ ] 8 GitHub secrets add kiye
- [ ] Code push kiya
- [ ] Build successful hua (green checkmark)
- [ ] APK aur AAB download kiye
- [ ] Slack notification aaya
- [ ] Screenshot liya

---

## 🎯 Important Commands

```bash
# Project mein jao
cd ~/Desktop/UNITY/unity2d-prototype

# Status check karo
git status

# Files add karo
git add .

# Commit karo
git commit -m "Your message"

# Push karo
git push origin main

# Logs dekho
git log --oneline

# Remote check karo
git remote -v
```

---

## 🔧 Troubleshooting

### Build Fail Ho Gaya?

1. **Check Secrets**: Sab 8 secrets sahi hain?
2. **Check License**: UNITY_LICENSE mein poora .ulf content hai?
3. **Check Keystore**: Base64 encoding sahi hai?
4. **Check Logs**: GitHub Actions mein error logs dekho

### Slack Notification Nahi Aaya?

```bash
# Test karo webhook
curl -X POST -H 'Content-type: application/json' \
--data '{"text":"Test message"}' \
YOUR_WEBHOOK_URL
```

### Keystore Error?

```bash
# Naya keystore banao
rm user.keystore keystore.txt
keytool -genkey -v -keystore user.keystore -alias myalias -keyalg RSA -keysize 2048 -validity 10000
base64 user.keystore > keystore.txt
```

---

## 📚 Documentation Files

**Zaroori**:
- `.github/workflows/android-build.yml` - Main pipeline
- `README.md` - Project description

**Recommended**:
- `CI-CD-SETUP-GUIDE.md` - Detailed English guide
- `SUBMISSION-CHECKLIST.md` - Submission checklist

**Optional** (Delete kar sakte ho):
- `QUICK-START.md`
- `LINUX-SETUP.md`
- `validate-setup.sh`
- `setup-without-unity.sh`
- `FILES-EXPLANATION.md`
- `URDU-QUICK-GUIDE.md` (this file)

---

## 🚀 Submission Ke Liye

**Provide karo**:
1. Repository URL: `https://github.com/YOUR_USERNAME/unity2d-prototype`
2. Screenshot: `screenshots/successful-build.png`
3. Documentation: `CI-CD-SETUP-GUIDE.md`
4. Time estimate: Setup time aur build time

**Make sure**:
- Repository public hai ya evaluator ko access diya
- All 8 secrets configured hain
- Build successful hai (green checkmark)
- Artifacts download ho sakte hain
- Slack notification working hai

---

## ⏱️ Time Estimate

- Keystore: 10 minutes
- Slack: 5 minutes
- Unity License: 15 minutes
- GitHub Secrets: 10 minutes
- First Build: 30 minutes
- **Total**: ~70 minutes (1 hour 10 minutes)

---

## 🎉 Done!

Sab kuch complete hone ke baad:
1. ✅ Pipeline working
2. ✅ APK aur AAB generated
3. ✅ Slack notifications working
4. ✅ Screenshot liya
5. ✅ Ready to submit!

**Good luck! 🚀**
