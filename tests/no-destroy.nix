{
  pkgs ? import <nixpkgs> { },
  diskoLib ? pkgs.callPackage ../lib { },
}:

diskoLib.testLib.makeDiskoTest (
  let
    configFile = pkgs.writeTextFile {
      name = "multi-device-no-destroy-config";
      text = builtins.readFile ../example/multi-device-no-destroy.nix;
    };
  in
  {
    inherit pkgs;
    name = "multi-device-no-destroy";
    disko-config = ../example/multi-device-no-destroy.nix;
    extraTestScript = ''
      # Write a test file to the data disk after initial provisioning
      machine.succeed("echo -n disko > /mnt/mnt/data/test.txt");
      # Reprovision the system using the same Disko config (root disk will be reformatted)
      machine.succeed("${pkgs.coreutils}/bin/cp ${configFile} /tmp/multi-device-no-destroy.nix");
      machine.succeed("${pkgs.disko}/bin/disko --mode destroy,format,mount /tmp/multi-device-no-destroy.nix --yes-wipe-all-disks");
      # Verify the data disk still contains the test file with correct content
      machine.succeed("grep -Fx disko /mnt/mnt/data/test.txt");
    '';
  }
)
