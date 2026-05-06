{ config, lib, pkgs, ... }:

let
  authorizedKeys = lib.splitString "\n"
    (lib.fileContents ../public_keys/keys);

  authorizedKeysFile = pkgs.writeText "authorized_keys"
    (lib.concatStringsSep "\n" (lib.filter (l: l != "" && !(lib.hasPrefix "#" l)) authorizedKeys));

  sshdConfig = pkgs.writeText "sshd_config" ''
    Port 22
    AddressFamily any
    Protocol 2

    HostKey /etc/ssh/system-manager/ssh_host_ed25519_key
    HostKey /etc/ssh/system-manager/ssh_host_rsa_key

    PermitRootLogin no
    PasswordAuthentication no
    KbdInteractiveAuthentication no
    PubkeyAuthentication yes
    AuthorizedKeysFile /etc/ssh/system-manager/authorized_keys.d/%u

    UsePAM yes
    X11Forwarding no
    PrintMotd no
    AcceptEnv LANG LC_*

    ClientAliveInterval 60
    ClientAliveCountMax 3

    Subsystem sftp ${pkgs.openssh}/libexec/sftp-server
  '';
in
{
  config = {
    nixpkgs.hostPlatform = "aarch64-linux";

    environment.systemPackages = [ pkgs.openssh ];

    environment.etc = {
      "ssh/system-manager/sshd_config".source = sshdConfig;
      "ssh/system-manager/authorized_keys.d/masatonoguchi" = {
        source = authorizedKeysFile;
        mode = "0644";
      };
    };

    systemd.tmpfiles.rules = [
      "d /etc/ssh/system-manager 0755 root root -"
    ];

    systemd.services.sshd-system-manager = {
      description = "OpenSSH server (managed by system-manager)";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      wants = [ "network.target" ];

      serviceConfig = {
        Type = "simple";
        ExecStartPre = "${pkgs.openssh}/bin/ssh-keygen -A -f /etc/ssh/system-manager";
        ExecStart = "${pkgs.openssh}/sbin/sshd -D -e -f /etc/ssh/system-manager/sshd_config";
        Restart = "on-failure";
        RestartSec = "5s";
      };
    };
  };
}
