import ./make-test.nix ({ pkgs, ... }:

let
  snakeOilPrivateKey = pkgs.writeText "privkey.snakeoil" ''
    -----BEGIN EC PRIVATE KEY-----
    MHcCAQEEIHQf/khLvYrQ8IOika5yqtWvI0oquHlpRLTZiJy5dRJmoAoGCCqGSM49
    AwEHoUQDQgAEKF0DYGbBwbj06tA3fd/+yP44cvmwmHBWXZCKbS+RQlAKvLXMWkpN
    r1lwMyJZoSGgBHoUahoYjTh9/sJL7XLJtA==
    -----END EC PRIVATE KEY-----
  '';

  snakeOilPublicKey = pkgs.lib.concatStrings [
    "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHA"
    "yNTYAAABBBChdA2BmwcG49OrQN33f/sj+OHL5sJhwVl2Qim0vkUJQCry1zFpKTa"
    "9ZcDMiWaEhoAR6FGoaGI04ff7CS+1yybQ= sakeoil"
  ];

in {
  name = "openssh";
  meta = with pkgs.stdenv.lib.maintainers; {
    maintainers = [ aszlig eelco chaoflow ];
  };

  nodes = {

    server =
      { config, pkgs, ... }:

      {
        services.openssh.enable = true;
        security.pam.services.sshd.limits =
          [ { domain = "*"; item = "memlock"; type = "-"; value = 1024; } ];
        users.extraUsers.root.openssh.authorizedKeys.keys = [
          snakeOilPublicKey
        ];
        users.extraUsers.testuser = {
          openssh.authorizedKeys.keys = [
            snakeOilPublicKey
          ];
          home = "/home/testuser";
          createHome = true;
          isNormalUser = true;
          shell = "${pkgs.zsh}/bin/zsh";
        };
        environment.systemPackages = [ pkgs.rsync ];
      };

    server_with_extrapath =
      { config, pkgs, ... }: {
        services.openssh = {
          enable = true;
          extraPackages = [ pkgs.rsync ];
        };
        security.pam.services.sshd.limits =
          [ { domain = "*"; item = "memlock"; type = "-"; value = 1024; } ];
        users.extraUsers.root.openssh.authorizedKeys.keys = [
          snakeOilPublicKey
        ];
        users.extraUsers.testuser = {
          openssh.authorizedKeys.keys = [
            snakeOilPublicKey
          ];
          home = "/home/testuser";
          createHome = true;
          isNormalUser = true;
          shell = "${pkgs.zsh}/bin/zsh";
        };
      };

    client =
      { config, pkgs, ... }: { };

  };

  testScript = ''
    startAll;

    my $key=`${pkgs.openssh}/bin/ssh-keygen -t ed25519 -f key -N ""`;

    $server->waitForUnit("sshd");

    subtest "manual-authkey", sub {
      $server->succeed("mkdir -m 700 /root/.ssh");
      $server->copyFileFromHost("key.pub", "/root/.ssh/authorized_keys");

      $client->succeed("mkdir -m 700 /root/.ssh");
      $client->copyFileFromHost("key", "/root/.ssh/id_ed25519");
      $client->succeed("chmod 600 /root/.ssh/id_ed25519");

      $client->waitForUnit("network.target");
      $client->succeed("ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no server 'echo hello world' >&2");
      $client->succeed("ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no server 'ulimit -l' | grep 1024");
    };

    subtest "configured-authkey", sub {
      $client->succeed("cat ${snakeOilPrivateKey} > privkey.snakeoil");
      $client->succeed("chmod 600 privkey.snakeoil");
      $client->succeed("ssh -o UserKnownHostsFile=/dev/null" .
                       " -o StrictHostKeyChecking=no -i privkey.snakeoil" .
                       " server true");
    };

    $server_with_extrapath->waitForUnit("sshd");
    subtest "call_rsync_over_ssh", sub {
      $server_with_extrapath->succeed("mkdir -m 700 /home/testuser/.ssh");
      $server_with_extrapath->copyFileFromHost("key.pub", "/home/testuser/.ssh/authorized_keys");

      # testuser, who uses zsh as shell, cannot call rsync over ssh directly without
      # an interactive shell
      $client->fail("ssh -o UserKnownHostsFile=/dev/null" .
                    " -o StrictHostKeyChecking=no -i privkey.snakeoil" .
                    " -l testuser server 'rsync --version'");
      # If he explicitely sources /etc/profile and set-up the environment, it goes fine
      $client->succeed("ssh -o UserKnownHostsFile=/dev/null" .
                       " -o StrictHostKeyChecking=no -i privkey.snakeoil" .
                       " -l testuser server 'source /etc/profile && rsync --version'");
      # If openssh is built with default path, there is no need to source /etc/profile to
      # have the desired programs as soon as the ssh session is started.
      $client->succeed("ssh -o UserKnownHostsFile=/dev/null" .
                       " -o StrictHostKeyChecking=no -i privkey.snakeoil" .
                       " -l testuser server_with_extrapath 'rsync --version'");
    }
  '';
})
