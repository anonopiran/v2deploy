local docker_compose = import './docker-compose.jsonnet';
local conf_v2f = import './config-v2f.jsonnet';
local conf_traefik = import './config-traefik.jsonnet';
{
    'docker-compose.yaml': std.manifestYamlDoc(docker_compose),
    'config-v2fly.json': std.toString(conf_v2f),
    'config-traefik.yaml': std.manifestYamlDoc(conf_traefik)
}