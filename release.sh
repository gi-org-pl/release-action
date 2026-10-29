#!/usr/bin/env bash
set -euo pipefail

bump="${1:-patch}"
case "$bump" in
  patch | minor | major) ;;
  *)
    echo "Unknown bump '$bump', use patch, minor or major" >&2
    exit 1
    ;;
esac

git fetch --quiet --force --tags origin
sha=$(git rev-parse HEAD)

if git tag --points-at "$sha" | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' > /dev/null; then
  echo "$sha is already released"
  exit 0
fi

latest=$(git tag --list 'v*' --sort=-v:refname | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | head -n 1 || true)

if [ -z "$latest" ]; then
  version=v1.0.0
else
  IFS=. read -r major minor patch <<< "${latest#v}"
  case "$bump" in
    major) major=$((major + 1)); minor=0; patch=0 ;;
    minor) minor=$((minor + 1)); patch=0 ;;
    patch) patch=$((patch + 1)) ;;
  esac
  version="v$major.$minor.$patch"
fi
major_tag="${version%%.*}"

notes=(--generate-notes)
if [ -n "$latest" ]; then
  notes+=(--notes-start-tag "$latest")
fi

gh release create "$version" --target "$sha" --title "$version" "${notes[@]}"
git tag --force "$major_tag" "$sha"
git push --quiet --force origin "refs/tags/$major_tag"

echo "version=$version" >> "${GITHUB_OUTPUT:-/dev/null}"
echo "Released $version and moved $major_tag to $sha"
