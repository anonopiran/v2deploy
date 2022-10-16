local context = import '../data/context.jsonnet';
{
  http: {
    services: {
      [x.tag]: { loadBalancer: { servers: [{ url: (if x.net == 'ws' then 'http://' else 'h2c://') + 'banana-v2f-host:' + x.port }] } }
      for x in context.v2f.inbounds
    },
    routers: {
      [x.tag + '-router']: { rule: 'Host(`' + context.traefik.url + '`) && Path(`' + x.path + '`)', service: x.tag, tls: { certresolver: 'le' } }
      for x in context.v2f.inbounds
    },
  },
}
