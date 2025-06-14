#! /nix/store/xy4jjgw87sbgwylm5kn047d9gkbhsr9x-bash-5.2p37/bin/bash -e
export DOTNET_ROOT='/nix/store/8gbasrdawfk04nfw8f7k3fz8621nzv5d-dotnet-runtime-wrapped-8.0.16/share/dotnet'
PATH=${PATH:+':'$PATH':'}
PATH=${PATH/':''/nix/store/8gbasrdawfk04nfw8f7k3fz8621nzv5d-dotnet-runtime-wrapped-8.0.16/bin'':'/':'}
PATH='/nix/store/8gbasrdawfk04nfw8f7k3fz8621nzv5d-dotnet-runtime-wrapped-8.0.16/bin'$PATH
PATH=${PATH#':'}
PATH=${PATH%':'}
export PATH
LD_LIBRARY_PATH=${LD_LIBRARY_PATH:+':'$LD_LIBRARY_PATH':'}
LD_LIBRARY_PATH=${LD_LIBRARY_PATH/':''/nix/store/i4lj3w4yd9x9jbi7a1xhjqsr7bg8jq7p-icu4c-76.1/lib'':'/':'}
LD_LIBRARY_PATH='/nix/store/i4lj3w4yd9x9jbi7a1xhjqsr7bg8jq7p-icu4c-76.1/lib'$LD_LIBRARY_PATH
LD_LIBRARY_PATH=${LD_LIBRARY_PATH#':'}
LD_LIBRARY_PATH=${LD_LIBRARY_PATH%':'}
export LD_LIBRARY_PATH
dotnet --info $@
exec "/nix/store/rc7xm5gapcnrii98vnqf8da8g9lkzpx5-jellysearch-0-unstable-2025-04-09/lib/jellysearch/jellysearch"  "$@" 
