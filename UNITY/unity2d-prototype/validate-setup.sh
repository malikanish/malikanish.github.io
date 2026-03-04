#!/bin/bash

# CI/CD Setup Validation Script
# This script helps verify your setup is correct before running the pipeline

echo "🔍 Unity CI/CD Pipeline Setup Validator"
echo "========================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Counters
PASSED=0
FAILED=0
WARNINGS=0

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to print status
print_status() {
    if [ "$1" = "pass" ]; then
        echo -e "${GREEN}✓${NC} $2"
        ((PASSED++))
    elif [ "$1" = "fail" ]; then
        echo -e "${RED}✗${NC} $2"
        ((FAILED++))
    elif [ "$1" = "warn" ]; then
        echo -e "${YELLOW}⚠${NC} $2"
        ((WARNINGS++))
    fi
}

echo "1. Checking Prerequisites..."
echo "----------------------------"

# Check Git
if command_exists git; then
    GIT_VERSION=$(git --version)
    print_status "pass" "Git installed: $GIT_VERSION"
else
    print_status "fail" "Git not found. Install from: https://git-scm.com/"
fi

# Check Java (for keystore)
if command_exists java; then
    JAVA_VERSION=$(java -version 2>&1 | head -n 1)
    print_status "pass" "Java installed: $JAVA_VERSION"
else
    print_status "warn" "Java not found. Needed for keystore creation."
fi

# Check keytool
if command_exists keytool; then
    print_status "pass" "Keytool available (for Android keystore)"
else
    print_status "warn" "Keytool not found. Install Java JDK."
fi

# Check curl (for Slack testing)
if command_exists curl; then
    print_status "pass" "Curl installed (for webhook testing)"
else
    print_status "warn" "Curl not found. Install for webhook testing."
fi

echo ""
echo "2. Checking Project Structure..."
echo "--------------------------------"

# Check if we're in the right directory
if [ -d "Assets" ] && [ -d "ProjectSettings" ]; then
    print_status "pass" "Unity project structure detected"
else
    print_status "fail" "Not in Unity project root. Run from unity2d-prototype folder."
fi

# Check for workflow file
if [ -f ".github/workflows/android-build.yml" ]; then
    print_status "pass" "Workflow file exists"
else
    print_status "fail" "Workflow file missing: .github/workflows/android-build.yml"
fi

# Check Unity version
if [ -f "ProjectSettings/ProjectVersion.txt" ]; then
    UNITY_VERSION=$(grep "m_EditorVersion:" ProjectSettings/ProjectVersion.txt | cut -d' ' -f2)
    print_status "pass" "Unity version: $UNITY_VERSION"
    
    if [[ "$UNITY_VERSION" != "2022.1.10f1" ]]; then
        print_status "warn" "Unity version mismatch. Workflow expects 2022.1.10f1"
    fi
else
    print_status "fail" "ProjectVersion.txt not found"
fi

# Check for Android build support
if [ -d "Library/PackageCache/com.unity.modules.androidjni@1.0.0" ] || \
   grep -q "com.unity.modules.androidjni" "Packages/manifest.json" 2>/dev/null; then
    print_status "pass" "Android modules detected"
else
    print_status "warn" "Android build support may not be installed"
fi

echo ""
echo "3. Checking Git Configuration..."
echo "--------------------------------"

# Check if git repo
if [ -d ".git" ]; then
    print_status "pass" "Git repository initialized"
    
    # Check remote
    if git remote -v | grep -q "github.com"; then
        REMOTE_URL=$(git remote get-url origin)
        print_status "pass" "GitHub remote configured: $REMOTE_URL"
    else
        print_status "fail" "No GitHub remote found. Add with: git remote add origin <url>"
    fi
    
    # Check current branch
    CURRENT_BRANCH=$(git branch --show-current)
    print_status "pass" "Current branch: $CURRENT_BRANCH"
    
    if [[ "$CURRENT_BRANCH" != "main" ]] && [[ "$CURRENT_BRANCH" != "master" ]]; then
        print_status "warn" "Not on main branch. Workflow triggers on 'main' branch."
    fi
else
    print_status "fail" "Not a git repository. Run: git init"
fi

echo ""
echo "4. Checking Required Files..."
echo "-----------------------------"

# Check for important Unity files
FILES_TO_CHECK=(
    "Assets"
    "ProjectSettings/ProjectSettings.asset"
    "Packages/manifest.json"
)

for file in "${FILES_TO_CHECK[@]}"; do
    if [ -e "$file" ]; then
        print_status "pass" "$file exists"
    else
        print_status "fail" "$file missing"
    fi
done

# Check for documentation
if [ -f "CI-CD-SETUP-GUIDE.md" ]; then
    print_status "pass" "Setup guide available"
else
    print_status "warn" "Setup guide not found"
fi

if [ -f "QUICK-START.md" ]; then
    print_status "pass" "Quick start guide available"
else
    print_status "warn" "Quick start guide not found"
fi

echo ""
echo "5. GitHub Secrets Checklist..."
echo "------------------------------"
echo "⚠ Cannot verify secrets automatically. Please confirm manually:"
echo ""
echo "Go to: https://github.com/YOUR_USERNAME/YOUR_REPO/settings/secrets/actions"
echo ""
echo "Required secrets (8 total):"
echo "  [ ] UNITY_LICENSE"
echo "  [ ] UNITY_EMAIL"
echo "  [ ] UNITY_PASSWORD"
echo "  [ ] ANDROID_KEYSTORE"
echo "  [ ] ANDROID_KEYSTORE_PASS"
echo "  [ ] ANDROID_KEY_ALIAS"
echo "  [ ] ANDROID_KEY_ALIAS_PASS"
echo "  [ ] SLACK_WEBHOOK_URL"
echo ""

echo "6. Validation Summary..."
echo "------------------------"
echo -e "${GREEN}Passed: $PASSED${NC}"
echo -e "${YELLOW}Warnings: $WARNINGS${NC}"
echo -e "${RED}Failed: $FAILED${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ Setup looks good! You can proceed with the pipeline.${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Configure GitHub Secrets (see checklist above)"
    echo "2. Push to main branch: git push origin main"
    echo "3. Check GitHub Actions tab for build progress"
    exit 0
else
    echo -e "${RED}✗ Please fix the failed checks before proceeding.${NC}"
    echo ""
    echo "See CI-CD-SETUP-GUIDE.md for detailed instructions."
    exit 1
fi
