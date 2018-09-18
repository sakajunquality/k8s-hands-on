# k8s-hands-on

## How to start

### Create volume

```bash
docker volume create k8s-hands-on
```

### Run Container

```bash
docker container run --rm -it \
     -v /var/run/docker.sock:/var/run/docker.sock \
     -v fargate-handson:/root/config \
     -p 8080:8080 sakajunquality/k8s-hands-on
```

### Open the Browser

- [http://localhost:8080](http://localhost:8080)
- Password: `sakajunquality`
- follow the instruction on notebooks

## Clean up

```bash
docker volume rm k8s-hands-on%
```
