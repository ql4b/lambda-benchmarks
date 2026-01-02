# FROM ghcr.io/ql4b/lambda-shell-runtime:tiny-latest
FROM public.ecr.aws/lambda/provided:al2023

WORKDIR /var/runtime
COPY app/src/bootstrap .

WORKDIR /var/task
COPY app/src/handler.sh .
