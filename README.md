# dots-ocr-docker-ready-setup

A ready-to-use Docker Compose setup for local deployment of [dots.ocr](https://github.com/rednote-hilab/dots.ocr), a powerful OCR solution.

## Overview

This repository provides a Docker Compose configuration that simplifies the deployment of dots.ocr in a containerized environment. It includes all necessary configurations for running the OCR service with GPU acceleration using vLLM.

## Prerequisites

- Docker and Docker Compose installed
- NVIDIA GPU with Docker GPU support (nvidia-docker2)
- **Hardware Requirement**: RTX3060 with 12G VRAM (minimum)
- Python 3.x for downloading model weights

## Setup Instructions

### 1. Download Model Weights

Before running the Docker setup, you need to download the required LLM model weights from the official dots.ocr repository.

**Important Note:** Please use a directory name without periods (e.g., `DotsOCR` instead of `dots.ocr`) for the model save path. This is a temporary workaround pending integration with Transformers.

```bash
# Clone the official dots.ocr repository
git clone https://github.com/rednote-hilab/dots.ocr.git
cd dots.ocr

# Download model weights using the official tool
python3 tools/download_model.py

# Alternative: Download with modelscope
python3 tools/download_model.py --type modelscope
```

### 2. Create Model Directory

First, create the model directory structure in your current project root folder:

```bash
# Navigate to your project root directory
cd /path/to/dots-ocr-docker-ready-setup

# Create the model directory structure
mkdir -p model/weights
```

### 3. Copy Model Files

After downloading the model weights, copy the downloaded files to the current project's model folder:

```bash
# Copy the downloaded model files to the project directory
# Replace 'path/to/downloaded/DotsOCR' with the actual path where models were downloaded
cp -r path/to/downloaded/DotsOCR model/weights/
```

### 4. Configure Docker Settings

Edit the `docker-compose.yml` file to customize your configuration:

#### GPU Configuration

```yaml
deploy:
  resources:
    reservations:
      devices:
        - driver: nvidia
          device_ids: ["0"] # Change this to your desired GPU ID
          capabilities: [gpu]
```

#### Port Configuration

You can modify the exposed port if your local port 8000 is already in use:

```yaml
ports:
  - "8001:8000" # Change 8001 to any available port on your system
```

#### Model Name Configuration

You can customize the LLM model name from the default "dots_ocr" to a better name:

```yaml
command: [
    # ... other parameters ...
    "--served-model-name",
    "your_custom_model_name", # Change this to your preferred name
    # ... other parameters ...
  ]
```

**Important Note**: If you change the model name, you need to update the corresponding code in the original dots.ocr project to use the new model name when making API calls.

### 5. Run the Service

Start the dots.ocr service using Docker Compose:

```bash
docker-compose up -d
```

The service will be available at `http://localhost:8000`.

## Configuration

The Docker setup includes:

- **Base Image**: vllm/vllm-openai:v0.9.1
- **GPU Support**: NVIDIA runtime with configurable GPU allocation
- **Port Mapping**: Service runs on port 8000 (mapped from container port 8000)
- **Model Path**: `/app/weights/DotsOCR` inside the container
- **Memory Settings**: Optimized for GPU memory utilization (95%)

## Service Parameters

The vLLM server is configured with the following parameters:

- Tensor parallel size: 1
- GPU memory utilization: 95%
- Max model length: 72,768 tokens
- Max number of sequences: 2
- Data type: bfloat16
- Swap space: 4GB
- Block size: 16

## Troubleshooting

1. **GPU Not Detected**: Ensure nvidia-docker2 is properly installed and configured
2. **Model Loading Issues**: Verify that model files are correctly copied to `model/weights/DotsOCR`
3. **Memory Issues**: Adjust `--gpu-memory-utilization` parameter in docker-compose.yml
4. **Port Conflicts**: Change the port mapping in docker-compose.yml if port 8000 is already in use

## Related Links

- [Official dots.ocr Repository](https://github.com/rednote-hilab/dots.ocr)
- [vLLM Documentation](https://docs.vllm.ai/)

## License

This Docker setup follows the same license as the original dots.ocr project.
