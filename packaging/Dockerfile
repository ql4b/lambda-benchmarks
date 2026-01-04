FROM public.ecr.aws/lambda/provided:al2023 AS builder

RUN dnf update -y && dnf install -y golang

WORKDIR /build
COPY app/runtime/* .
RUN go build \
  -ldflags="-s -w -extldflags '-static'" \
  -trimpath \
  -buildmode=exe \
  -a \
  -installsuffix cgo \
  -o bootstrap main.go

FROM public.ecr.aws/lambda/provided:al2023

# Copy Go bootstrap
COPY --from=builder /build/bootstrap /var/runtime/bootstrap
RUN chmod +x /var/runtime/bootstrap

# Copy shell function
COPY app/src/handler.sh /var/task/handler.sh
RUN chmod +x /var/task/handler.sh