
HTTP_PORT=${HTTP_PORT-9980}

function rpc {
  method=${1?rpc method name}
  params=${2?rpc parameters in json format}
  echo $method $params
  curl http://test:test@localhost:${HTTP_PORT}/rpc --data-binary '{"method":"'"${method}"'","params":['"${params}"'],"id":0}"'
}

