{ pkgs }:
let
  # Pull Lumerical Image
  lumericalImage = pkgs.dockerTools.pullImage {
    imageName = "jatsekku/lumerical";
    imageDigest = "sha256:5c4fcd6cfaf5fdab87095751bf854976587beda567b13ed730dd3fa8e0b3d97f";
    hash = "sha256-nsZfz1v9V9GFwvGNVIroYpUYRtYopQ5WlgkMx5TTWIg=";

    finalImageName = "lumerical";
  };

  docker-launcher-scriptContent = builtins.readFile ../scripts/docker-launcher.sh;
in
pkgs.writeShellApplication {
  name = "lumerical-dockerized";
  runtimeInputs = [ pkgs.docker ];

  text = ''
    export DOCKER_IMAGE_TAR=${lumericalImage}

    ${docker-launcher-scriptContent}
  '';
}
