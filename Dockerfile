FROM ubuntu:20.04

ARG USER=android
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

RUN dpkg --add-architecture i386
RUN apt-get update && apt-get install -y \
        build-essential git neovim wget unzip sudo \
        libc6:i386 libncurses5:i386 libstdc++6:i386 lib32z1 libbz2-1.0:i386 \
        libxrender1 libxtst6 libxi6 libfreetype6 libxft2 xz-utils vim\
        qemu qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils libnotify4 libglu1 libqt5widgets5 openjdk-8-jdk openjdk-11-jdk xvfb \
        && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN groupadd -g 1000 -r $USER
RUN useradd -u 1000 -g 1000 --create-home -r $USER
RUN adduser $USER libvirt
RUN adduser $USER kvm
#Change password
RUN echo "$USER:$USER" | chpasswd
#Make sudo passwordless
RUN echo "${USER} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/90-$USER
RUN usermod -aG sudo $USER
RUN usermod -aG plugdev $USER
RUN mkdir -p /androidstudio-data
VOLUME /androidstudio-data
RUN chown $USER:$USER /androidstudio-data

RUN mkdir -p /studio-data/Android/Sdk && \
    chown -R $USER:$USER /studio-data/Android


RUN mkdir -p /studio-data/profile/android && \
    chown -R $USER:$USER /studio-data/profile

COPY provisioning/docker_entrypoint.sh /usr/local/bin/docker_entrypoint.sh
COPY provisioning/ndkTests.sh /usr/local/bin/ndkTests.sh
RUN chmod +x /usr/local/bin/*
COPY provisioning/51-android.rules /etc/udev/rules.d/51-android.rules

USER $USER

WORKDIR /home/$USER

#Install Flutter
ARG FLUTTER_URL=https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.22.1-stable.tar.xz
ARG FLUTTER_VERSION=3.22.1

RUN wget "$FLUTTER_URL" -O flutter.tar.xz
RUN tar -xvf flutter.tar.xz
RUN rm flutter.tar.xz

#Android Studio
ARG ANDROID_STUDIO_URL=https://redirector.gvt1.com/edgedl/android/studio/ide-zips/2023.3.1.19/android-studio-2023.3.1.19-linux.tar.gz

RUN wget "$ANDROID_STUDIO_URL" -O android-studio.tar.gz
RUN tar xzvf android-studio.tar.gz
RUN rm android-studio.tar.gz

WORKDIR /home/$USER/.config/
RUN ln -s /studio-data/profile/config/flutter flutter

WORKDIR /home/$USER/.config/Google
RUN ln -s /studio-data/profile/AndroidStudio2023.3 AndroidStudio2023.3

WORKDIR /home/$USER/.local/share/Google
RUN ln -s /studio-data/profile/consentOptions consentOptions

WORKDIR /home/$USER
RUN ln -s /studio-data/Android Android
RUN ln -s /studio-data/profile/android .android
RUN ln -s /studio-data/profile/java .java
RUN ln -s /studio-data/profile/gradle .gradle
RUN ln -s /studio-data/profile/vscode-server .vscode-server
RUN ln -s /studio-data/profile/pub-cache .pub-cache
RUN ln -s /studio-data/profile/dart-tool .dart-tool
RUN ln -s /studio-data/profile/bash_history .bash_history
RUN ln -s /studio-data/profile/flutter .flutter
RUN ln -s /projects projects
ARG HOME=/home/$USER
ENV ANDROID_HOME="$HOME/Android/Sdk"
ENV PATH="$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$ANDROID_HOME/cmdline-tools/latest/bin:$HOME/.pub-cache/bin:$HOME/flutter/bin"
ENV ANDROID_EMULATOR_USE_SYSTEM_LIBS=1

WORKDIR /home/$USER

ENTRYPOINT [ "/usr/local/bin/docker_entrypoint.sh" ]
