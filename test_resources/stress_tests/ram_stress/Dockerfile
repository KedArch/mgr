FROM golang:1.24.6 AS builder

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY ram_stress.go .

RUN CGO_ENABLED=0 GOOS=linux go build -o ram_stress .

FROM scratch

COPY --from=builder /app/ram_stress ram_stress

ENTRYPOINT ["/ram_stress"]

