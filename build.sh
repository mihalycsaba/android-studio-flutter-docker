mkdir -p studio-data/Android || exit
mkdir -p studio-data/profile/AndroidStudio2023.3 || exit
mkdir -p studio-data/profile/consentOptions || exit
mkdir -p studio-data/profile/android || exit
mkdir -p studio-data/profile/java || exit
mkdir -p studio-data/profile/gradle || exit
mkdir -p studio-data/profile/vscode-server || exit
mkdir -p studio-data/profile/pub-cache || exit
mkdir -p studio-data/profile/dart-tool || exit
mkdir -p studio-data/profile/config/flutter || exit
touch studio-data/profile/bash_history || exit
touch studio-data/profile/flutter || exit
mkdir -p projects || exit
docker build -t android-studio . || exit
