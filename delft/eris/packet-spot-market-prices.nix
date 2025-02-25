{ config, pkgs, ... }:
let
  exporter = pkgs.fetchFromGitHub {
    owner = "grahamc";
    repo = "prometheus-packet-spot-market-price-exporter";
    rev = "b894f5dc061e2ab2d0ef101c28fce390285ad492";
    sha256 = "sha256-I2WolAAM+siE8JfZbEZ3Mmk7/XqVio/PzUKqZUYCBfE=";
  };
in {
  deployment.keys.prometheus-packet-spot-market-price-exporter = {
    keyFile = /home/deploy/src/nixos-org-configurations/keys/prometheus-packet-spot-market-price-exporter-config.json;
    user = "spot-price-exporter";
  };

  users.users.spot-price-exporter = {
    description = "Prometheus Packet Spot Market Price Exporter";
    isSystemUser = true;
    group = "spot-price-exporter";
  };
  users.groups.spot-price-exporter = {};

  systemd.services.prometheus-packet-spot-market-price-exporter = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      User = "spot-price-exporter";
      Group = "keys";
      Restart = "always";
      RestartSec = "60s";
      PrivateTmp =  true;
    };

    path = [
      (pkgs.python3.withPackages (p: [ p.prometheus_client p.requests ]))
    ];

    script = "exec python3 ${exporter}/scrape.py /run/keys/prometheus-packet-spot-market-price-exporter";
  };
}
