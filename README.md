# Build Ren'Py Project

This GitHub action allows you to make distributable builds of a Ren'Py visual novel project in a workflow and use the built files for distribution.

## Usage

```yml
- name: Build VN project
  uses: ProjectAliceDev/renpy-build-action@master
  with:
    sdk-version: '6.99.12.4'
    project-dir: '.'
  env:
    SDL_AUDIODRIVER: dummy
    SDL_VIDEODRIVER: dummy
```

**Required Parameters:**

- `sdk-version`: The version of the Ren'Py SDK to use while building. Will default to `7.3.2` if none is found.

- `project-dir`: The directory where the project exists. Will default to `'.'` (root) if none is found.

> :warning: If you are targeting Ren'Py v7.4.0+, you must use v1.1.2 of this action or greater.

**Optional Parameters:**

- `package`: Specific package to build for. Must be one of the following: `pc`, `mac`, `linux`, `market`, `web`, `android`. Will build for all packages if value is not supported.

- `add-steam-lib`: Whether to include Steam lib. This is necessary if you want your build to work with Steam achievements. Defaults to `false`.

### Outputs

- `dir`: The directory where the files were built to.
- `version`: The name of the project and version that was built. Often useful in cases where you don't know the version.
