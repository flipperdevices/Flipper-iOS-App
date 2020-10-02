# Lint with systemwide installation if present
if which swiftlint >/dev/null; then
  swiftlint
  exit 0
fi
# Download a copy of swiftlint if it doesn't exist in project root
if [ ! -f swiftlint ]; then
  curl -o- -Ls https://github.com/realm/SwiftLint/releases/latest/download/portable_swiftlint.zip | tar xzf - swiftlint \
  && chmod +x swiftlint || echo "warning: Failed to download SwiftLint"; exit 0
fi
# Lint with local swiftlint
./swiftlint
