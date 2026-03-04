#!/bin/bash

# Complete CI/CD Setup Script (Without Unity Installation)
# This script helps you setup everything needed for the CI/CD pipeline

set -e

echo "🚀 Unity CI/CD Pipeline Setup (No Unity Installation Required!)"
echo "================================================================"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Check if we're in the right directory
if [ ! -d "Assets" ] || [ ! -d "ProjectSettings" ]; then
    echo -e "${RED}Error: Please run this script from the unity2d-prototype directory${NC}"
    echo "Run: cd ~/Desktop/UNITY/unity2d-prototype"
    exit 1
fi

echo -e "${BLUE}Step 1: Installing Java (for Android Keystore)${NC}"
echo "------------------------------------------------"
if command -v java >/dev/null 2>&1; then
    echo -e "${GREEN}✓ Java already installed${NC}"
    java -version
else
    echo "Installing OpenJDK..."
    sudo apt update
    sudo apt install openjdk-11-jdk -y
    echo -e "${GREEN}✓ Java installed${NC}"
fi
echo ""

echo -e "${BLUE}Step 2: Creating Android Keystore${NC}"
echo "----------------------------------"
if [ -f "user.keystore" ]; then
    echo -e "${YELLOW}⚠ Keystore already exists. Skipping...${NC}"
else
    echo "Creating keystore..."
    echo ""
    echo "You'll be asked for:"
    echo "  1. Keystore password (remember this!)"
    echo "  2. Your name and organization details"
    echo "  3. Key password (press Enter to use same as keystore password)"
    echo ""
    read -p "Press Enter to continue..."
    
    keytool -genkey -v -keystore user.keystore -alias myalias -keyalg RSA -keysize 2048 -validity 10000
    
    if [ -f "user.keystore" ]; then
        echo -e "${GREEN}✓ Keystore created successfully${NC}"
        
        # Convert to base64
        base64 user.keystore > keystore.txt
        echo -e "${GREEN}✓ Base64 encoded keystore saved to keystore.txt${NC}"
        
        echo ""
        echo -e "${YELLOW}IMPORTANT: Save this information!${NC}"
        echo "Keystore file: user.keystore"
        echo "Key alias: myalias"
        echo "Base64 file: keystore.txt"
        echo ""
    else
        echo -e "${RED}✗ Keystore creation failed${NC}"
        exit 1
    fi
fi
echo ""

echo -e "${BLUE}Step 3: Creating GitHub Activation Workflow${NC}"
echo "--------------------------------------------"
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

echo -e "${GREEN}✓ Activation workflow created${NC}"
echo ""

echo -e "${BLUE}Step 4: Checking Git Configuration${NC}"
echo "-----------------------------------"
if git remote -v | grep -q "github.com"; then
    REMOTE_URL=$(git remote get-url origin)
    echo -e "${GREEN}✓ Git remote configured${NC}"
    echo "Remote: $REMOTE_URL"
    
    if echo "$REMOTE_URL" | grep -q "practical-works"; then
        echo ""
        echo -e "${YELLOW}⚠ WARNING: You're using the original repository!${NC}"
        echo "You need to create YOUR OWN repository on GitHub."
        echo ""
        echo "Steps:"
        echo "1. Go to: https://github.com/new"
        echo "2. Create repository: unity2d-prototype"
        echo "3. Run: git remote set-url origin https://github.com/YOUR_USERNAME/unity2d-prototype.git"
        echo "4. Run: git push -u origin main"
        echo ""
        read -p "Press Enter after you've created your repository..."
    fi
else
    echo -e "${RED}✗ No GitHub remote found${NC}"
    echo "Add remote: git remote add origin https://github.com/YOUR_USERNAME/unity2d-prototype.git"
    exit 1
fi
echo ""

echo -e "${BLUE}Step 5: Summary of Next Steps${NC}"
echo "------------------------------"
echo ""
echo "✅ Java installed"
echo "✅ Android keystore created"
echo "✅ Workflow files ready"
echo ""
echo -e "${YELLOW}What you need to do next:${NC}"
echo ""
echo "1️⃣  Setup Slack Webhook:"
echo "   • Go to: https://api.slack.com/apps"
echo "   • Create app → Incoming Webhooks → Activate"
echo "   • Copy webhook URL"
echo ""
echo "2️⃣  Get Unity License:"
echo "   • Push code: git add . && git commit -m 'Setup CI/CD' && git push"
echo "   • Go to: https://github.com/YOUR_USERNAME/unity2d-prototype/actions"
echo "   • Run 'Get Unity Activation File' workflow"
echo "   • Download .alf file"
echo "   • Go to: https://license.unity3d.com/manual"
echo "   • Upload .alf, download .ulf"
echo ""
echo "3️⃣  Configure GitHub Secrets:"
echo "   • Go to: https://github.com/YOUR_USERNAME/unity2d-prototype/settings/secrets/actions"
echo "   • Add 8 secrets (see list below)"
echo ""
echo "4️⃣  Trigger Build:"
echo "   • Push to main branch"
echo "   • Watch: https://github.com/YOUR_USERNAME/unity2d-prototype/actions"
echo ""
echo -e "${BLUE}Required GitHub Secrets:${NC}"
echo "------------------------"
echo "1. UNITY_LICENSE          → Content from .ulf file"
echo "2. UNITY_EMAIL            → Your Unity account email"
echo "3. UNITY_PASSWORD         → Your Unity account password"
echo "4. ANDROID_KEYSTORE       → Content from keystore.txt (already created)"
echo "5. ANDROID_KEYSTORE_PASS  → Password you entered for keystore"
echo "6. ANDROID_KEY_ALIAS      → myalias"
echo "7. ANDROID_KEY_ALIAS_PASS → Key password (same as keystore if you pressed Enter)"
echo "8. SLACK_WEBHOOK_URL      → Webhook URL from Slack"
echo ""
echo -e "${GREEN}Files created:${NC}"
echo "• user.keystore (keep this safe!)"
echo "• keystore.txt (use for ANDROID_KEYSTORE secret)"
echo "• .github/workflows/get-activation.yml"
echo "• .github/workflows/android-build.yml"
echo ""
echo -e "${YELLOW}⚠ IMPORTANT: Add keystore files to .gitignore${NC}"
echo ""

# Add to gitignore
if ! grep -q "user.keystore" .gitignore 2>/dev/null; then
    echo "user.keystore" >> .gitignore
    echo "keystore.txt" >> .gitignore
    echo "*.keystore" >> .gitignore
    echo -e "${GREEN}✓ Added keystore files to .gitignore${NC}"
fi

echo ""
echo -e "${GREEN}🎉 Setup Complete!${NC}"
echo ""
echo "Next command to run:"
echo -e "${BLUE}git add . && git commit -m 'Setup CI/CD pipeline' && git push${NC}"
echo ""
echo "For detailed instructions, see:"
echo "• LINUX-SETUP.md"
echo "• CI-CD-SETUP-GUIDE.md"
echo "• QUICK-START.md"
echo ""
