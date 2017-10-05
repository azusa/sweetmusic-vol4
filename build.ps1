docker build -t tf3 .
docker run tf3

$out = docker ps -a |Select-String "tf3"
foreach ($line in $out){
  $ids = $line.line -split " "
  $id = ${ids}[0]
  & docker cp ${id}:/tmp/code/target .
  docker rm $id
}

