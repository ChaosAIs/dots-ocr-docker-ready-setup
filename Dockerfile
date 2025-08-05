FROM vllm/vllm-openai:v0.9.1

# Install additional dependencies
RUN apt-get update && apt-get install -y build-essential ninja-build && rm -rf /var/lib/apt/lists/*
RUN pip install flash_attn==2.8.0.post2 transformers==4.51.3 tokenizers psutil

# Create app directory
WORKDIR /app

# Copy model weights and source code
COPY model/weights /app/weights

# Set environment variables exactly like the local setup
ENV hf_model_path=/app/weights/DotsOCR
ENV PYTHONPATH=/app/weights

# Create entrypoint script that replicates the exact local setup process
COPY <<EOF /app/entrypoint.sh
#!/bin/bash
set -e

echo "=== DotsOCR vLLM Docker Setup ==="
echo "Model path: \$hf_model_path"
echo "PYTHONPATH: \$PYTHONPATH"

# Step 1: Register model to vLLM (exactly like local setup)
echo "Registering DotsOCR model with vLLM..."
sed -i '/^from vllm\\.entrypoints\\.cli\\.main import main\$/a\\
from DotsOCR import modeling_dots_ocr_vllm' \$(which vllm)

echo "vLLM registration completed successfully"

# Step 2: Launch vLLM server with passed arguments
echo "Starting vLLM server..."
exec vllm serve "\$@"
EOF

RUN chmod +x /app/entrypoint.sh

ENTRYPOINT ["/app/entrypoint.sh"]
