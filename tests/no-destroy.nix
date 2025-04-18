{
  pkgs ? import <nixpkgs> { },
  diskoLib ? pkgs.callPackage ../lib { },
}:

diskoLib.testLib.makeDiskoTest ({
  inherit pkgs;
  name = "multi-device-no-destroy";
  disko-config = ../example/multi-device-no-destroy.nix;
  extraTestScript = ''
    # Write a test file to the data disk after initial provisioning
    machine.succeed("echo -n disko > /mnt/data/test.txt");

    # Reprovision the system using the same Disko config (root disk should be
    # reformatted, but not the data disk)
    machine.succeed("${pkgs.coreutils}/bin/cp -vf '${../example/multi-device-no-destroy.nix}' /tmp/disko-config.nix");

    machine.succeed("cat -A /tmp/disko-config.nix >&2");
    machine.succeed("${pkgs.disko}/bin/disko --debug --mode destroy,format,mount /tmp/disko-config.nix --yes-wipe-all-disks");

    # Verify the data disk still contains the test file with correct content
    machine.succeed("${pkgs.gnugrep}/bin/grep -Fx disko /mnt/data/test.txt");
  '';
})
