Adjust hosts file

make build

docker build -t haystack-deployment .

docker run --rm -it -v /var/run/docker.sock:/var/run/docker.sock -v "$(pwd)/config:/app/config" haystack-deployment