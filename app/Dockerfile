FROM golang:1.10.1-alpine as build

WORKDIR /go/src/github.com/sakajunquality/hello-go-docker
COPY main.go main.go

RUN go get -d -v ./...
RUN go install -v ./...

FROM alpine
RUN apk add --no-cache ca-certificates
COPY --from=build /go/bin/hello-go-docker /usr/local/bin/hello-go-docker

CMD ["hello-go-docker"]
