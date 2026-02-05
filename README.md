# Build Ren'Py Project

This GitHub action allows you to make distributable builds of a Ren'Py visual novel project in a workflow and use the built files for distribution.

## Usage

```yml
- name: Build VN project
  uses: ProjectAliceDev/renpy-build-action@master
  with:
    sdk-version: '8.5.2'
    project-dir: '.'
    package: 'linux win mac'
    add-steam-lib: false
    output-dir: './dist'
  env:
    SDL_AUDIODRIVER: dummy
    SDL_VIDEODRIVER: dummy
```

**Required Parameters:**

- `sdk-version`: The version of the Ren'Py SDK to use while building. Will default to `7.3.2` if none is found.

- `project-dir`: The directory where the project exists. Will default to `'.'` (root) if none is found.

> :warning: If you are targeting Ren'Py v7.4.0+, you must use v1.1.2 of this action or greater.

**Optional Parameters:**

- `package`: Specific package(s) to build for. Supported values: `pc`, `win`, `mac`, `linux`, `market`, `web`, `android`.
  You can provide multiple targets as a space-separated string (e.g. `linux win mac`). If omitted, it will build the default distribution.

- `add-steam-lib`: Whether to include Steam lib. This is necessary if you want your build to work with Steam achievements. Defaults to `false`.

- `output-dir`: The directory where the built files will be placed. Defaults to `./dist`.

### Outputs

- `dir`: The directory where the files were built to (the `output-dir`).
- `version`: The project version detected from Ren'Py (from `build.version` or `config.version`).

### Android Example

Building for Android requires Java 21 and Android SDK to be installed.
Environment variables must also be set so that the Android SDK is installed in the workspace.

```yml
env:
  ANDROID_SDK_ROOT: ${{ github.workspace }}/.android-sdk
  ANDROID_HOME: ${{ github.workspace }}/.android-sdk
steps:
  - name: Setup Java 21
    uses: actions/setup-java@v4
    with:
      distribution: temurin
      java-version: "21"

  - name: Setup Android SDK
    uses: android-actions/setup-android@v3.2.2
    with:
      log-accepted-android-sdk-licenses: false

  - name: Build Android APK
    id: build
    uses: ProjectAliceDev/renpy-build-action@master
    with:
      sdk-version: '8.5.2'
      package: android
    env:
      SDL_AUDIODRIVER: dummy
      SDL_VIDEODRIVER: dummy
```

> :warning: In order to sign the Android APK, you must provide an `android.keystore` file in the project directory. The keystore file should be stored in GitHub Secrets and copied to a file in the project directory before building. See: https://www.renpy.org/doc/html/android.html