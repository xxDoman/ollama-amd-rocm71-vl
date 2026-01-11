FROM ubuntu:24.04
ENV DEBIAN_FRONTEND=noninteractive

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      wget curl ca-certificates gnupg tar xz-utils pciutils \
      libnuma1 zlib1g libtinfo6 libxml2 libelf1 libdrm2 libdrm-amdgpu1; \
    rm -rf /var/lib/apt/lists/*

# --- AMDGPU/ROCm installer helper (userspace only) ---
COPY amdgpu-install_7.1.70100-1_all.deb /tmp/amdgpu-install.deb
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends /tmp/amdgpu-install.deb; \
    rm -f /tmp/amdgpu-install.deb; \
    \
    # FIX: repo repo.radeon.com/amdgpu/7.1/ubuntu noble daje 404 -> usuwamy je z sources
    (grep -RIl 'repo\.radeon\.com/amdgpu/7\.1/ubuntu' /etc/apt/sources.list.d || true) | while read -r f; do \
      sed -i '/repo\.radeon\.com\/amdgpu\/7\.1\/ubuntu/d' "$f"; \
    done; \
    \
    apt-get update; \
    amdgpu-install --usecase=rocm,hip --no-dkms --no-32 --accept-eula -y; \
    rm -rf /var/lib/apt/lists/*

# Linker paths
RUN set -eux; \
    printf '%s\n' \
      '/opt/rocm/lib' \
      '/opt/rocm/hip/lib' \
      '/opt/rocm/llvm/lib' \
      > /etc/ld.so.conf.d/rocm.conf; \
    ldconfig

# --- Tensile/“tenzory” for gfx906 (override) ---
COPY 906/ /opt/rocm/lib/rocblas/library/

# --- Your Ollama 0.13.5 build (no downloads) ---
COPY ollama-0.13.5-rocm-gfx906.tgz /tmp/ollama.tgz
RUN set -eux; \
    mkdir -p /tmp/ollama_unpack; \
    tar -xzf /tmp/ollama.tgz -C /tmp/ollama_unpack; \
    install -m 0755 /tmp/ollama_unpack/ollama /usr/local/bin/ollama; \
    mkdir -p /usr/local/lib/ollama; \
    cp -a /tmp/ollama_unpack/lib/ollama/* /usr/local/lib/ollama/; \
    rm -rf /tmp/ollama.tgz /tmp/ollama_unpack; \
    printf '%s\n' /usr/local/lib/ollama > /etc/ld.so.conf.d/ollama.conf; \
    ldconfig

# No models in image
ENV OLLAMA_MODELS=/models
VOLUME ["/models"]

# Runtime env
ENV OLLAMA_HOST=0.0.0.0:11434 \
    OLLAMA_LLM_LIBRARY=rocm \
    OLLAMA_LIBRARY_PATH=/usr/local/lib/ollama \
    LD_LIBRARY_PATH=/usr/local/lib/ollama:/opt/rocm/lib:/opt/rocm/hip/lib:/opt/rocm/llvm/lib \
    ROCBLAS_TENSILE_LIBPATH=/opt/rocm/lib/rocblas/library \
    HSA_OVERRIDE_GFX_VERSION=9.0.6

EXPOSE 11434
CMD ["ollama","serve"]
