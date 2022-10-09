local context = import '../data/context.jsonnet';
{
  services: {
    traefik: {
      image: 'traefik:latest',
      ports: [
        context.traefik.port + ':' + context.traefik.port,
      ],
      volumes: [
        './traefik-data:/data',
        './config-traefik.yaml:/config-dir/config-traefik.yaml',
      ],
      environment: {
        TRAEFIK_ENTRYPOINTS_V2F: 'true',
        TRAEFIK_ENTRYPOINTS_V2F_ADDRESS: ':' + context.traefik.port,
        TRAEFIK_PROVIDERS_FILE_DIRECTORY: '/config-dir',
        TRAEFIK_PROVIDERS_FILE_WATCH: 'false',
        TRAEFIK_LOG: 'true',
        TRAEFIK_LOG_LEVEL: context.traefik.log_level,
        TRAEFIK_CERTIFICATESRESOLVERS_LE: 'true',
        TRAEFIK_CERTIFICATESRESOLVERS_LE_ACME_EMAIL: context.traefik.email,
        TRAEFIK_CERTIFICATESRESOLVERS_LE_ACME_STORAGE: '/data/acme.json',
        TRAEFIK_CERTIFICATESRESOLVERS_LE_ACME_HTTPCHALLENGE: 'true',
        TRAEFIK_CERTIFICATESRESOLVERS_LE_ACME_HTTPCHALLENGE_ENTRYPOINT: 'V2F',
      },
      restart: 'unless-stopped',
    },
    v2fly: {
      image: 'v2fly/v2fly-core:latest',
      hostname: 'v2f-host',
      volumes: [
        './config-v2fly.json:/etc/v2ray/config.json',
      ],
      environment: {
        'v2ray.vmess.aead.forced': 'false',
      },
      depends_on: ['traefik'],
      restart: 'unless-stopped',
    },
  },
}
