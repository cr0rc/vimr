#!/bin/bash
set -Eeuo pipefail

readonly code_sign=${code_sign:?"true or false"}
readonly use_carthage_cache=${use_carthage_cache:?"true or false"}
readonly local_nvimserver=${local_nvimserver:-"false"}

main () {
  pushd "$(dirname "${BASH_SOURCE[0]}")/.." >/dev/null
  echo "### Building VimR target"

  local -r build_path="./build"

  # Carthage often crashes => do it at the beginning.
  echo "### Updating carthage"
  if [[ "${use_carthage_cache}" == true ]]; then
    carthage update --cache-builds --platform macos
  else
    carthage update --platform macos
  fi

  if [[ "${local_nvimserver}" == false ]]; then
    echo "### Downloading NVimServer"
    ./bin/download_nvimserver.sh
  fi

  echo "### Xcodebuilding"
  rm -rf ${build_path}

  xcodebuild -configuration Release -derivedDataPath ${build_path} \
    -workspace VimR.xcworkspace -scheme VimR \
    clean build

  if [[ "${code_sign}" == true ]]; then
      local -r -x vimr_app_path="${build_path}/Build/Products/Release/VimR.app"
      ./bin/sign_vimr.sh
  fi

  echo "### Built VimR target"
  popd >/dev/null
}

main
