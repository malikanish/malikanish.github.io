#!/bin/bash

# Final Cleanup Script - Sirf Zaroori Files Rakhega

echo "🧹 Cleaning up - Sirf zaroori files rakhenge"
echo "============================================"
echo ""

# Delete extra guidance files
echo "Deleting optional files..."

rm -f QUICK-START.md
rm -f LINUX-SETUP.md
rm -f FILES-EXPLANATION.md
rm -f URDU-QUICK-GUIDE.md
rm -f validate-setup.sh
rm -f setup-without-unity.sh
rm -f cleanup-optional-files.sh

echo "✅ Cleanup complete!"
echo ""
echo "📁 Remaining files:"
echo ""
ls -lh *.md 2>/dev/null
echo ""
echo "✅ Files kept:"
echo "  - README.md (MUST)"
echo "  - CI-CD-SETUP-GUIDE.md (Recommended)"
echo "  - SUBMISSION-CHECKLIST.md (Recommended)"
echo "  - .github/workflows/android-build.yml (MUST)"
echo ""
echo "Now run: git add . && git status"
