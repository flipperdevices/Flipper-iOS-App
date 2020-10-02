# Lint with systemwide installation if present
if which swiftlint >/dev/null; then
  swiftlint
  exit 0
fi
# Lint with local swiftlint copy if present
if [ -f swiftlint ]; then
  ./swiftlint
else
  # Download a copy of swiftlint to project root and lint afterwards
  curl -o- -Ls https://github.com/realm/SwiftLint/releases/latest/download/portable_swiftlint.zip | tar xzf - swiftlint \
  && chmod +x swiftlint || echo "warning: Failed to download SwiftLint"; exit 0
  ./swiftlint 
fi