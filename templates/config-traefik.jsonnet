local context = import '../data/context.jsonnet';
{
  http: {
    services: {
      [x.tag]: { loadBalancer: { servers: [{ url: (if x.net == 'ws' then 'http://' else 'h2c://') + 'banana-v2f-host:' + x.port }] } }
      for x in context.v2f.inbounds
    },
    routers: {
      [x.tag + '-router']: { rule: 'Path(`'+ (if x.net == "grpc" then '/' else '') + x.path + (if x.net == "grpc" then '/Tun' else '') +'`)', service: x.tag, tls: true }
      for x in context.v2f.inbounds
    },
  },
  tls: {
      certificates:[
        {certFile: '/cert/fullchain.pem',keyFile: '/cert/privatekey.pem'}
      ]
    }
}
