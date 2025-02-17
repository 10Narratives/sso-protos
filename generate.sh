# Function to display help message
show_help() {
    echo "Usage: $0 [OPTIONS] <proto_file> <output_dir>"
    echo "Generate Go and/or gRPC code from a .proto file."
    echo
    echo "Options:"
    echo "  -t, --type TYPE       Specify the type of code to generate. TYPE can be 'go', 'grpc', or 'both'."
    echo "  -h, --help            Show this help message and exit."
    echo
    echo "Arguments:"
    echo "  <proto_file>          Path to the .proto file."
    echo "  <output_dir>          Directory to store the generated code."
    echo
    echo "Example:"
    echo "  $0 -t both proto/sso/sso.proto ./gen/go"
    exit 0
}

# Initialize variables
GENERATE_GO=false
GENERATE_GRPC=false
PROTO_FILE=""
OUTPUT_DIR=""

# Parse command-line options
while [[ "$#" -gt 0 ]]; do
    case $1 in
    -t | --type)
        case "$2" in
        go)
            GENERATE_GO=true
            ;;
        grpc)
            GENERATE_GRPC=true
            ;;
        both)
            GENERATE_GO=true
            GENERATE_GRPC=true
            ;;
        *)
            echo "Error: Invalid type '$2'. Valid options are 'go', 'grpc', or 'both'."
            exit 1
            ;;
        esac
        shift 2
        ;;
    -h | --help)
        show_help
        ;;
    *)
        if [[ -z "$PROTO_FILE" ]]; then
            PROTO_FILE="$1"
        elif [[ -z "$OUTPUT_DIR" ]]; then
            OUTPUT_DIR="$1"
        else
            echo "Error: Unexpected argument '$1'."
            exit 1
        fi
        shift
        ;;
    esac
done

# Validate required arguments
if [[ -z "$PROTO_FILE" || -z "$OUTPUT_DIR" ]]; then
    echo "Error: Missing required arguments."
    show_help
fi

# Create the output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"
if [[ $? -ne 0 ]]; then
    echo "Error: Failed to create output directory '$OUTPUT_DIR'."
    exit 1
fi

# Run the protoc command based on the selected type
if $GENERATE_GO; then
    echo "Generating Go code..."
    protoc -I $(dirname "$PROTO_FILE") "$PROTO_FILE" \
        --go_out="$OUTPUT_DIR" \
        --go_opt=paths=source_relative
fi

if $GENERATE_GRPC; then
    echo "Generating gRPC code..."
    protoc -I $(dirname "$PROTO_FILE") "$PROTO_FILE" \
        --go-grpc_out="$OUTPUT_DIR" \
        --go-grpc_opt=paths=source_relative
fi

# Check if the command was successful
if [[ $? -eq 0 ]]; then
    echo "Code generation completed successfully in $OUTPUT_DIR"
else
    echo "Failed to generate code"
    exit 1
fi
