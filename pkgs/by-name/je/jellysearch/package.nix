{
  lib,
  buildDotnetModule,
  fetchFromGitLab,
  dotnetCorePackages,
}:

buildDotnetModule {
  pname = "jellysearch";
  version = "0-unstable-2025-04-09";

  src = fetchFromGitLab {
    owner = "DomiStyle";
    repo = "jellysearch";
    rev = "7397e3f8c7daa6f0d30b22dda7c5159a913ca6b8";
    hash = "sha256-7t0j4S5A9yvRN8zjToMNsxJ72OjU3j++EAqq9CKcPaI=";
  };

  projectFile = "src/JellySearch.sln";
  # dotnet-sdk = dotnetCorePackages.sdk_8_0;
  # dotnet-runtime = dotnetCorePackages.runtime_8_0;
  nugetDeps = ./deps.json;
  executables = [ "jellysearch" ];

  meta = {
    description = "A fast full-text search proxy for Jellyfin";
    homepage = "https://gitlab.com/DomiStyle/jellysearch";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "jellysearch";
    platforms = lib.platforms.all;
  };
}
