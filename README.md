# Build Ren'Py Project

This GitHub action allows you to make distributable builds of a Ren'Py visual novel project in a workflow and use the built files for distribution.

## Usage

```yml
- name: Build VN project
  uses: ProjectAliceDev/renpy-build-action@master
  with:
    sdk-version: '6.99.12.4'
  env:
    SDL_AUDIODRIVER: dummy
    SDL_VIDEODRIVER: dummy
```

> Note: This action will assume that the Ren'Py project is the repository's root rather than a separate directory.

**Required Parameters:**

- `sdk-version`: The version of the Ren'Py SDK to use while building. Will default to `7.3.2` if none is found.

### Outputs

- `dir`: The directory where the files were built to.
- `version`: The name of the project and version that was built. Often useful in cases where you don't know the version.
