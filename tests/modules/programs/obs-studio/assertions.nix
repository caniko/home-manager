{pkgs, ...}: let
  obsPackage = pkgs.runCommand "obs" {passthru = {};} ''
    mkdir -p $out/bin $out/share/obs/obs-plugins
    printf '#!${pkgs.runtimeShell}\n' > $out/bin/obs
    chmod +x $out/bin/obs
  '';
in {
  test.asserts.assertions.expected = [
    "programs.obs-studio.integrations.*.enable requires a matching derivation in pkgs.obs-studio-plugins or an explicit package override."
    "programs.obs-studio.sceneCollections.Bad.currentScene must reference a declared scene."
    "programs.obs-studio.sceneCollections.Bad.scenes.*.items.*.source must reference a declared source."
    "programs.obs-studio.sceneCollections.Bad.sources.*.settings must not contain RestoreToken unless portal.restoreToken is explicitly set."
  ];

  programs.obs-studio = {
    enable = true;
    package = obsPackage;
    sceneCollections.Bad = {
      currentScene = "Missing";
      sources.desktop = {
        id = "pipewire-screen-capture-source";
        settings.RestoreToken = "machine-local-token";
      };
      scenes.Main.items = [
        {source = "missing-source";}
      ];
    };
    integrations.missing-plugin.enable = true;
  };
}
