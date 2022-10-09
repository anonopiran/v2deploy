local context = import '../data/context.jsonnet';
local user_uid = import '../data/user-uid.jsonnet';
local template = {
  stream_ws: {
    network: 'ws',
    wsSettings: {},
    security: 'none',
  },
  stream_grpc: {
    network: 'grpc',
    grpcSettings: {},
    security: 'none',
  },
  user_vmess: [{ email: x + '@v2.fly', id: x, level: 0 } for x in user_uid],
  user_trojan: [{ email: x + '@v2.fly', password: x, level: 0 } for x in user_uid],
};
{
  log: {
    loglevel: context.v2f.log_level,
    access: 'none',
  },
  routing: {
    domainStrategy: 'IPIfNonMatch',
    rules: [
      {
        type: 'field',
        ip: [
          'geoip:private',
          '0.0.0.0',
        ],
        outboundTag: 'block',
      },
    ],
  },
  dns: {
    servers: context.v2f.dns,
  },
  inbounds: [
    {
      port: x.port,
      listen: '0.0.0.0',
      protocol: x.proto,
      settings: {
        clients: if x.proto == 'vmess' then template.user_vmess else template.user_trojan,
      },
      streamSettings: if x.net == 'ws' then template.stream_ws { wsSettings+: { path: x.path } } else template.stream_grpc { grpcSettings+: { serviceName: x.path } },
      tag: x.tag,
    }
    for x in context.v2f.inbounds
  ],
  outbounds: [
    {
      protocol: 'freedom',
      settings: {
        domainStrategy: 'AsIs',
      },
      tag: 'direct',
    },
    {
      protocol: 'blackhole',
      settings: {
        type: 'http',
      },
      tag: 'block',
    },
  ],
}
