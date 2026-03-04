#!/bin/bash

# Cleanup Optional Files Script
# Ye script extra guidance files ko delete kar dega

echo "🧹 Cleaning up optional files..."
echo ""

cd ~/Desktop/UNITY/unity2d-prototype

# Files to delete (optional guidance files)
FILES_TO_DELETE=(
    "QUICK-START.md"
    "LINUX-SETUP.md"
    "validate-setup.sh"
    "setup-without-unity.sh"
    "FILES-EXPLANATION.md"
    "cleanup-optional-files.sh"
)

echo "Files that will be deleted:"
for file in "${FILES_TO_DELETE[@]}"; do
    if [ -f "$file" ]; then
        echo "  ❌ $file"
    fi
done

echo ""
echo "Files that will be KEPT:"
echo "  ✅ .github/workflows/android-build.yml (MUST)"
echo "  ✅ README.md (MUST)"
echo "  ✅ CI-CD-SETUP-GUIDE.md (Recommended)"
echo "  ✅ SUBMISSION-CHECKLIST.md (Recommended)"
echo "  ✅ All Unity project files (MUST)"
echo ""

read -p "Delete optional files? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    for file in "${FILES_TO_DELETE[@]}"; do
        if [ -f "$file" ]; then
            rm "$file"
            echo "  Deleted: $file"
        fi
    done
    echo ""
    echo "✅ Cleanup complete!"
    echo ""
    echo "Remaining files:"
    ls -la *.md .github/workflows/*.yml 2>/dev/null
else
    echo "Cleanup cancelled."
fi
