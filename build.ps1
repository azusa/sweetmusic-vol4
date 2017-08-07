docker build -t tf2 .
docker run tf2

$out = docker ps -a |Select-String "tf2"
foreach ($line in $out){
  $ids = $line.line -split " "
  $id = ${ids}[0]
  & docker cp ${id}:/tmp/code/target .
  docker rm $id
}

