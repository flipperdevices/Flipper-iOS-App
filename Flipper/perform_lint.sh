# Download a copy of swiftlint if it doesn't exist nor systemwide neither in project root
if ! command -v swiftlint >/dev/null && [ ! -f swiftlint ]; then
  (curl -o- -Ls https://github.com/realm/SwiftLint/releases/latest/download/portable_swiftlint.zip | tar xzf - swiftlint \
  && chmod +x swiftlint) || (echo "warning: Failed to download SwiftLint"; exit 0)
fi
# Lint with local swiftlint
swiftlint || ./swiftlint
