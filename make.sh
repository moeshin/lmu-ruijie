#!/usr/bin/env bash

version='1.0.0'

workdir="$(cd "$(dirname "$0")" && pwd)"

if [[ -z "$GOOS" ]]; then
  uname="$(uname)"
  case "$uname" in
  CYGWIN* | MINGW* | MSYS* )
    platform='windows'
    ;;
  Darwin* )
    platform='darwin'
    ;;
  Linux* )
    if getprop >/dev/null 2>&1 && [ "$(getprop net.bt.name)" ==  'Android' ]; then
      platform='android'
    else
      platform='linux'
    fi
    ;;
  * )
    echo "Unkown uname: $uname"
    exit 1
  esac
else
  platform="$GOOS"
fi

build_dir="$workdir/build/$platform"

mkdir -p "$build_dir"

exec_path="$build_dir/login"

if [[ "$platform" == "windows" ]]; then
  exec_path="$exec_path.exe"
fi

go build -ldflags "-s -w -X main._VERSION_=$version" -o "$exec_path"

echo "输出文件夹: $build_dir"

function cprs() {
  cp "$workdir/$1" "$build_dir/$2"
}

cprs config-sample.ini

case "$platform" in
windows | darwin | linux )
  cp "$workdir/services/$platform/"* "$build_dir"
  ;;
esac
