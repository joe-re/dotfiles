{ config, lib, pkgs, ... }:

let
  authorizedKeys = lib.splitString "\n"
    (lib.fileContents ../public_keys/keys);

  authorizedKeysFile = pkgs.writeText "authorized_keys"
    (lib.concatStringsSep "\n" (lib.filter (l: l != "" && !(lib.hasPrefix "#" l)) authorizedKeys));

  sshdConfig = pkgs.writeText "sshd_config" ''
    Port 22
    AddressFamily inet
    Protocol 2

    HostKey /etc/ssh/system-manager/ssh_host_ed25519_key

    PermitRootLogin no
    PasswordAuthentication no
    KbdInteractiveAuthentication no
    PubkeyAuthentication yes
    AuthorizedKeysFile /etc/ssh/system-manager/authorized_keys.d/%u

    # Restrict source IPs to RFC1918 private ranges + loopback.
    AllowUsers *@10.0.0.0/8 *@172.16.0.0/12 *@192.168.0.0/16 *@127.0.0.0/8

    # Disabled: Nix-built sshd's PAM lib chokes on Ubuntu's @include
    # directives in /etc/pam.d/sshd. Pubkey auth doesn't need PAM.
    UsePAM no
    X11Forwarding no
    PrintMotd no
    AcceptEnv LANG LC_*

    MaxAuthTries 3
    LoginGraceTime 30
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
      # OpenSSH privsep chroot dir; must be empty and root-owned.
      "d /var/empty 0755 root root -"
    ];

    systemd.services.sshd-system-manager = {
      description = "OpenSSH server (managed by system-manager)";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      wants = [ "network.target" ];

      serviceConfig = {
        Type = "simple";
        ExecStartPre = pkgs.writeShellScript "sshd-system-manager-prep" ''
          set -euo pipefail

          # Privilege-separation user required by OpenSSH. Create if missing.
          if ! /usr/bin/getent passwd sshd >/dev/null; then
            /usr/sbin/useradd --system \
              --no-create-home \
              --home-dir /run/sshd \
              --shell /usr/sbin/nologin \
              --user-group \
              --comment "Privilege-separated SSH" \
              sshd
          fi

          # Host key: generate if missing.
          dir=/etc/ssh/system-manager
          for t in ed25519; do
            f="$dir/ssh_host_''${t}_key"
            if [ ! -e "$f" ]; then
              ${pkgs.openssh}/bin/ssh-keygen -t "$t" -N "" -f "$f"
            fi
          done
        '';
        ExecStart = "${pkgs.openssh}/bin/sshd -D -e -f /etc/ssh/system-manager/sshd_config";
        Restart = "on-failure";
        RestartSec = "5s";
      };
    };
  };
}
