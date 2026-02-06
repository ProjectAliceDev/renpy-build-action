FROM ubuntu:24.04

RUN apt-get update
RUN apt-get install --yes bzip2 wget libxext6 mesa-utils unzip rsync jq tree openjdk-21-jdk

# Android SDK location inside container
ENV ANDROID_SDK_ROOT=/opt/android-sdk
ENV ANDROID_HOME=/opt/android-sdk
ENV PATH="${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/platform-tools:${PATH}"

# Install Android cmdline tools (sdkmanager) then required SDK packages
RUN mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools \
  && cd /tmp \
  && wget -q -O cmdline-tools.zip https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip \
  && unzip -q cmdline-tools.zip \
  && mv cmdline-tools ${ANDROID_SDK_ROOT}/cmdline-tools/latest \
  && rm -f cmdline-tools.zip \
  && yes | sdkmanager --licenses >/dev/null \
  && sdkmanager --install "platform-tools"

COPY build.sh /build.sh

ENTRYPOINT ["/build.sh"]
