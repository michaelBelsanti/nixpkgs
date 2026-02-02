#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq nix-prefetch-git
set -euo pipefail

DIR="$(dirname "$(readlink -f "$0")")"
NIX_FILE="$DIR/package.nix"
NIXPKGS="$(git -C "$DIR" rev-parse --show-toplevel)"

err() { echo "ERROR: $*" >&2; exit 1; }

# -- falcond (latest release tag) --
latest_tag=$(curl -sSf "https://api.github.com/repos/PikaOS-Linux/falcond/releases/latest" | jq -r '.tag_name') \
  || err "failed to fetch falcond release info"
version="${latest_tag#v}"
[[ -n "$version" ]] || err "empty version from falcond release"

old_version=$(grep -Po 'version = "\K[^"]*' "$NIX_FILE")
[[ -n "$old_version" ]] || err "could not parse version from $NIX_FILE"

if [[ "$old_version" != "$version" ]]; then
  falcond_hash=$(nix-prefetch-git --quiet --url "https://github.com/PikaOS-Linux/falcond" --rev "$latest_tag" --fetch-submodules | jq -r '.hash') \
    || err "failed to prefetch falcond"
  sed -i "s|version = \"$old_version\"|version = \"$version\"|" "$NIX_FILE"
  sed -i "/repo = \"falcond\"/,/rootDir/{
    s|hash = \"sha256-.*\"|hash = \"$falcond_hash\"|
  }" "$NIX_FILE"

  # Replace zigDeps FOD hash with fakeHash, then build to get the real one
  sed -i "/zigDeps = zig.fetchDeps/,/};/{
    s|hash = \"sha256-.*\"|hash = lib.fakeHash;|
  }" "$NIX_FILE"
  zigdeps_hash=$(nix-build --no-out-link "$NIXPKGS" -A falcond.zigDeps 2>&1 \
    | grep -oP 'got:\s+\Ksha256-\S+') \
    || err "failed to compute zigDeps hash"
  [[ -n "$zigdeps_hash" ]] || err "could not parse zigDeps hash from build output"
  sed -i "/zigDeps = zig.fetchDeps/,/};/{
    s|hash = lib.fakeHash;|hash = \"$zigdeps_hash\";|
  }" "$NIX_FILE"
fi

# -- falcond-profiles (main branch head) --
profiles_rev=$(curl -sSf "https://api.github.com/repos/PikaOS-Linux/falcond-profiles/git/ref/heads/main" | jq -r '.object.sha') \
  || err "failed to fetch falcond-profiles ref"
[[ -n "$profiles_rev" ]] || err "empty rev from falcond-profiles ref"

old_rev=$(grep -A4 'falcond-profiles-src' "$NIX_FILE" | grep -Po 'rev = "\K[^"]*')
[[ -n "$old_rev" ]] || err "could not parse profiles rev from $NIX_FILE"

if [[ "$old_rev" != "$profiles_rev" ]]; then
  profiles_hash=$(nix-prefetch-git --quiet --url "https://github.com/PikaOS-Linux/falcond-profiles" --rev "$profiles_rev" | jq -r '.hash') \
    || err "failed to prefetch falcond-profiles"
  sed -i "/falcond-profiles-src/,/};/{
    s|rev = \".*\"|rev = \"$profiles_rev\"|
    s|hash = \"sha256-.*\"|hash = \"$profiles_hash\"|
  }" "$NIX_FILE"
fi
