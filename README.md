# release-action

A GitHub Action that releases the next version of a GitHub Action and moves its major tag to it.

## Usage

```yaml
- name: Release the next version and move the major tag
  uses: gi-org-pl/release-action@v1
  with:
    bump: patch
```

Pin the action by commit SHA in your workflows, and let Dependabot keep the pin current.

## Inputs

| Input               | Description                                            | Required | Default               |
|---------------------|--------------------------------------------------------|----------|-----------------------|
| `bump`              | Part of the version to increase: patch, minor or major | No       | `patch`               |
| `token`             | Token that can create releases in the repository       | No       | `${{ github.token }}` |
| `working-directory` | Directory of the repository to release                 | No       | `.`                   |

## Outputs

| Output    | Description                                                             |
|-----------|-------------------------------------------------------------------------|
| `version` | The released version, such as `v1.2.3`, empty when nothing was released |

## Example workflow

```yaml
name: release

on:
  push:
    branches: [main]
    paths-ignore:
      - '.github/**'
      - '**.md'
  workflow_dispatch:
    inputs:
      bump:
        description: Part of the version to increase
        type: choice
        options: [patch, minor, major]
        default: patch

concurrency:
  group: release

permissions:
  contents: write

jobs:
  release:
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-24.04
    steps:
      - uses: actions/checkout@v7

      - name: Release the next version and move the major tag
        uses: gi-org-pl/release-action@v1
        with:
          bump: ${{ inputs.bump || 'patch' }}
```

Every change to the action released from `main` gets the next patch version. Run the workflow by hand to release a
minor or major version.

## How it works

The action fetches the tags and looks for the highest `vX.Y.Z` tag. If the checked-out commit already has one, it does
nothing. Otherwise it creates the next version as a GitHub release with generated notes, and force-pushes the major tag
(`vX`) to the same commit. A repository without releases starts at `v1.0.0`.

The workflow needs `contents: write`, and `actions/checkout` must keep its credentials (the default), because the
action pushes the major tag with them.

Protect released versions with a tag ruleset that blocks updating and deleting `*.*.*` tags. Leave the major tags out of
it, so the action can move them.

## Authors

Action author is [Oskar Barcz](https://github.com/oskarbarcz), CTO of **[Generacja Innowacja](https://gi.org.pl)** —
Poland's first technology-first NGO.

## License

MIT
