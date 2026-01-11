# Ollama + ROCm 7.1 dla AMD MI50 (gfx906) - Vision Language Support

https://hub.docker.com/r/xxdoman/ollama-amd-rocm71-vl

Pojedynczy obraz Docker do uruchomienia **Ollama z ROCm 7.1** na **AMD Instinct MI50 (gfx906)**. Ta wersja została zoptymalizowana pod kątem obsługi modeli **Vision Language (VL)**, takich jak Qwen3-VL.

* **Host OS:** Ubuntu 22.04 / 24.04 z działającym ROCm
* **GPU:** AMD Instinct MI50 (gfx906)
* **Cel:** Wnioskowanie na **GPU (ROCm)**, w tym obsługa modeli multimodalnych (Vision).

---

## English Documentation

### 1. What this image includes
* **Ubuntu 24.04** (minimal rootfs)
* **AMD ROCm 7.1** userspace (ROCm + HIP)
* **Ollama** with ROCm backend and Vision Language support
* Environment tuned for **AMD Instinct MI50 (gfx906)**

### 2. Quick Start (Pull from Docker Hub)
You can pull the latest pre-built image:
```bash
docker pull xxdoman/ollama-amd-rocm71:v1.0.1
```

### 3. Run the container
Recommended run with persistent models on host:
```bash 
mkdir -p /opt/ollama-models

docker run -d \
  --name ollama-amd-rocm71-vl \
  --device=/dev/kfd \
  --device=/dev/dri/renderD128 \
  --device=/dev/dri/renderD129 \
  --group-add video \
  -p 11434:11434 \
  -v /opt/ollama-models:/root/.ollama \
  xxdoman/ollama-amd-rocm71:v1.0.1 \
  ollama serve
```
### 4. Vision Language (VL) Testing
This image is specifically prepared to handle models like Qwen3-VL. To test it:
```bash 
docker exec -it ollama-amd-rocm71-vl ollama run qwen2-vl
```

#### Polski opis
Co zawiera obraz
Ubuntu 24.04 oraz ROCm 7.1 (userspace)
Ollama z backendem ROCm i wsparciem dla modeli Vision Language
Optymalizacja pod AMD Instinct MI50 (gfx906)
Szybkie uruchomienie
Pobierz gotowy obraz: 

```bash
docker pull xxdoman/ollama-amd-rocm71:v1.0.1
```

Uruchomienie z trwałym przechowywaniem modeli:

```bash
docker run -d \
  --name ollama-amd-rocm71-vl \
  --device=/dev/kfd \
  --device=/dev/dri/renderD128 \
  --device=/dev/dri/renderD129 \
  --group-add video \
  -p 11434:11434 \
  -v /opt/ollama-models:/root/.ollama \
  xxdoman/ollama-amd-rocm71:v1.0.1 \
  ollama serve
```

### Sprawdzenie statusu GPU
W logach kontenera powinieneś zobaczyć:
amdgpu is supported gpu_type=gfx906 oraz library=rocm.

Monitorowanie na hoście:

```bash 
/opt/rocm/bin/rocm-smi
```

Docker Hub: xxdoman/ollama-amd-rocm71-vl

https://hub.docker.com/repository/docker/xxdoman/ollama-amd-rocm71-vl/general
