# ============================================================
# llama.cpp CUDA build container
# Target: NVIDIA RTX 4060 Ti (SM 89)
# CUDA: 12.4
# OS: Ubuntu 22.04
# ============================================================

FROM nvidia/cuda:12.4.1-devel-ubuntu22.04

# ------------------------------------------------------------
# Fix: CUDA driver symbols are NOT present at build time
# Use CUDA stub libraries so linker succeeds
# ------------------------------------------------------------
ENV LIBRARY_PATH=/usr/local/cuda/lib64/stubs:$LIBRARY_PATH
ENV LD_LIBRARY_PATH=/usr/local/cuda/lib64/stubs:$LD_LIBRARY_PATH

# ------------------------------------------------------------
# System dependencies
# ------------------------------------------------------------
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------
# Workspace
# ------------------------------------------------------------
WORKDIR /app

# Copy llama.cpp source (expects this Dockerfile in repo root)
COPY . /app

# ------------------------------------------------------------
# Build llama.cpp with CUDA
# - CUDA ON
# - CURL OFF (avoids libcurl dependency)
# - Examples OFF (prevents libcuda link failures)
# ------------------------------------------------------------
RUN mkdir -p build && cd build && \
    cmake .. \
        -DGGML_CUDA=ON \
        -DLLAMA_CURL=OFF \
        -DLLAMA_BUILD_EXAMPLES=OFF \
        -DLLAMA_BUILD_TESTS=OFF \
        -DLLAMA_BUILD_TOOLS=OFF && \
    cmake --build . -j$(nproc)

# ------------------------------------------------------------
# Runtime defaults
# (libcuda.so will be injected at runtime by NVIDIA Container Toolkit)
# ------------------------------------------------------------
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility

# ------------------------------------------------------------
# Default entrypoint (override as needed)
# ------------------------------------------------------------
CMD ["/bin/bash"]
