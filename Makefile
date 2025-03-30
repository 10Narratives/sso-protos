PROTO_DIR := proto
GEN_DIR := gen/go
PROTO_FILES := $(shell find $(PROTO_DIR) -name '*.proto')

all: generate

generate: $(GEN_DIR)
	@echo "Generating Go and gRPC code..."
	protoc \
        -I $(PROTO_DIR) \
        --go_out=$(GEN_DIR) \
        --go_opt=paths=source_relative \
        --go-grpc_out=$(GEN_DIR) \
        --go-grpc_opt=paths=source_relative \
        $(PROTO_FILES)

$(GEN_DIR):
	@echo "Creating output directory: $@"
	mkdir -p $@

clean:
	@echo "Cleaning generated files..."
	rm -rf $(GEN_DIR)

help:
	@echo "Usage:"
	@echo "  make all       - Generate Go and gRPC code (default target)"
	@echo "  make generate  - Generate Go and gRPC code"
	@echo "  make clean     - Remove generated files"
	@echo "  make help      - Display this help message"

.PHONY: all generate clean help