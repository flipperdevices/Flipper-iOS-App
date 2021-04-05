# Download a copy of LicensePlist if it doesn't exist.
if [ ! -f license-plist ]; then
    (curl -o- -Ls https://github.com/mono0926/LicensePlist/releases/latest/download/portable_licenseplist.zip | tar xzf - license-plist \
    && chmod +x license-plist) || (echo "warning: Failed to download LicensePlist"; exit 0)
fi
# (Re-)collect and (re-)generate Settings.bundle with 3rd pty. licenses.
./license-plist --output-path Settings.bundle --add-version-numbers --prefix acknowledgements --config-path .license_plist.yml
