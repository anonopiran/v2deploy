local context = import '../data/context.jsonnet';
{
  version: "3",
  services: {
    banana_traefik: {
      image: 'traefik:latest',
      hostname: 'banana_traefik',
      ports: [
        context.traefik.port + ':' + context.traefik.port,
      ],
      volumes: [
        './traefik-data/data:/data',
        './traefik-data/config-traefik.yaml:/config-dir/config-traefik.yaml',
      ],
      environment: {
        TRAEFIK_ENTRYPOINTS_BANABA: 'true',
        TRAEFIK_ENTRYPOINTS_BANABA_ADDRESS: ':' + context.traefik.port,
        TRAEFIK_PROVIDERS_FILE_DIRECTORY: '/config-dir',
        TRAEFIK_PROVIDERS_FILE_WATCH: 'false',
        TRAEFIK_LOG: 'true',
        TRAEFIK_LOG_LEVEL: context.traefik.log_level,
        TRAEFIK_CERTIFICATESRESOLVERS_LE: 'true',
        TRAEFIK_CERTIFICATESRESOLVERS_LE_ACME_EMAIL: context.traefik.email,
        TRAEFIK_CERTIFICATESRESOLVERS_LE_ACME_STORAGE: '/data/acme.json',
        TRAEFIK_CERTIFICATESRESOLVERS_LE_ACME_HTTPCHALLENGE: 'true',
        TRAEFIK_CERTIFICATESRESOLVERS_LE_ACME_HTTPCHALLENGE_ENTRYPOINT: 'BANABA',
      },
      restart: 'unless-stopped',
    },
    banana_v2fly: {
      image: 'v2fly/v2fly-core:latest',
      hostname: 'banana-v2f-host',
      volumes: [
        './v2fly-data/config-v2fly.json:/etc/v2ray/config.json',
      ],
      environment: {
        'v2ray.vmess.aead.forced': 'false',
      },
      restart: 'unless-stopped',
    },
    banana_ghostunnel: {
      image: 'ghostunnel/ghostunnel:latest',
      ports: [
        context.ghostunnel.port+':'+context.ghostunnel.port,
      ],
      volumes: [
        './ghostunnel-data/fullchain.pem:/cert/fullchain.pem',
        './ghostunnel-data/privatekey.pem:/cert/privatekey.pem'
      ],
      command: [
        'server',
        '--listen=0.0.0.0:'+context.ghostunnel.port,
        '--target=banana_traefik:'+context.traefik.port,
        '--cert=/cert/fullchain.pem',
        '--key=/cert/privatekey.pem',
        '--unsafe-target',
        '--disable-authentication',
      ],
      restart: 'unless-stopped',
    },
  },
}
