#!/bin/bash

# Create fonts directory if it doesn't exist
mkdir -p assets/fonts

# Download Noto Sans Hebrew Regular from Google Fonts GitHub repository
curl -L "https://github.com/google/fonts/raw/main/ofl/notosanshebrew/NotoSansHebrew-Regular.ttf?raw=true" -o assets/fonts/NotoSansHebrew-Regular.ttf

# Download Noto Sans Hebrew Bold from Google Fonts GitHub repository
curl -L "https://github.com/google/fonts/raw/main/ofl/notosanshebrew/NotoSansHebrew-Bold.ttf?raw=true" -o assets/fonts/NotoSansHebrew-Bold.ttf

echo "Fonts downloaded successfully!" 