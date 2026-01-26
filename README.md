# Ollama 0.15.1 + ROCm 7.1 (VL) for AMD Instinct MI50 (gfx906)
Update 2026-01-26: Added support for Ollama v0.15.1. Dedicated Docker image optimized for AMD Instinct MI50 32 GB (gfx906) with ROCm 7.1 user-space and Tensile libraries.

Image Highlights
Ollama Version: 0.15.1

ROCm Version: 7.1 (included in image, host ROCm not required)

Target Hardware: gfx906 (MI50 / Vega 20)

Optimized Libraries: Full Tensile / rocBLAS support for MI50

Storage Path: Models are stored in /models (volume required)

Optimized Usage (32GB VRAM & 65k Context)
To leverage the 32GB VRAM for long context (65,536 tokens) with parallel processing, use the following command:

```Bash
docker run -d --name ollama-mi50-vl \
  --device=/dev/kfd \
  --device-cgroup-rule='c 226:* rmw' \
  -v /dev/dri:/dev/dri \
  -v ollama_models:/models \
  -p 11434:11434 \
  -e OLLAMA_MODELS=/models \
  -e OLLAMA_NUM_PARALLEL=1 \
  -e OLLAMA_KV_CACHE_TYPE=q4_0 \
  -e OLLAMA_MAX_LOADED_MODELS=1 \
  xxdoman/ollama-amd-rocm71-vl:latest
```
---
Enter the container
```Bash
docker exec -it ollama-mi50-vl bash
```
Create a modelfile (e.g., for Qwen3) using cat
```Bash
cat <<EOF> Modelfile
FROM qwen3-vl:8b
PARAMETER num_ctx 65536
EOF
```
Build a new version of the model
```Bash
ollama create qwen3-8b-65k -f Modelfile
```
---
Host Requirements
OS: Linux with AMDGPU/KFD driver enabled.

Device Nodes: Must expose /dev/kfd and /dev/dri/renderD*.

Available Tags
latest - Always points to the newest stable (currently 0.15.1).

0.13.5-full - Legacy stable version.

----


# Ollama 0.13.5 + ROCm 7.1 (VL) for AMD Instinct MI50 (gfx906)
Docker image with Ollama 0.13.5, ROCm 7.1 user‑space and Tensile libraries (gfx906), tested on AMD Radeon Instinct MI50 32 GB.

Docker Hub (repo):
https://hub.docker.com/r/xxdoman/ollama-amd-rocm71-vl 
- UPDATE 2026-01-26: Support for Ollama v0.15.1

Docker Hub (overview):
https://hub.docker.com/repository/docker/xxdoman/ollama-amd-rocm71-vl/general

Image highlights
Ollama: 0.13.5
ROCm: 7.1 (user‑space included in the image)
GPU target: gfx906 (MI50 / Vega 20)
Tensile / rocBLAS libraries included
No models included — models are stored in /models (Docker volume)
Host ROCm user‑space not required
Available tags:

latest
0.13.5-full
Host requirements
Linux with AMDGPU/KFD enabled
Must expose device nodes:
/dev/kfd
/dev/dri/renderD*
Docker
Quick host checks:
```bash
ls -l /dev/kfd
ls -l /dev/dri/renderD*
groups
```
Run

Create persistent volume for models:
```bash
docker volume create ollama_models
```
Run the container:
```bash
docker run -d --name ollama-mi50-vl \
  --device=/dev/kfd \
  --device-cgroup-rule='c 226:* rmw' \
  -v /dev/dri:/dev/dri \
  -v ollama_models:/models \
  -p 11434:11434 \
  xxdoman/ollama-amd-rocm71-vl:latest
```
Ollama API:

http://localhost:11434
Pull a model (into the volume)
Example: Qwen3‑VL 8B
```bash
docker exec -it ollama-mi50-vl ollama pull qwen3-vl:8b
```
Verify GPU (ROCm)
Check logs for ROCm/gfx906:
```bash
docker logs --tail=200 ollama-mi50-vl | egrep -i 'inference compute|ROCm|gfx906'
```
Expected: library=rocm and compute=gfx906.

Quick benchmark (optional)
Warm up 
```bash
curl -s http://127.0.0.1:11434/api/generate \
-H 'Content-Type: application/json' \
-d '{"model":"qwen3-vl:8b","prompt":"Warmup.","stream":false,"keep_alive":"10m","options":{"num_predict":64}}' \
| jq '{eval_count, eval_duration, total_duration}'
Speed test (tokens/s) for i in 1 2; do
```
```bash
curl -s http://127.0.0.1:11434/api/generate \
-H 'Content-Type: application/json' \
-d '{"model":"qwen3-vl:8b","prompt":"Napisz długi tekst po polsku.","stream":false,"keep_alive":"10m","options":{"num_predict":512,"temperature":0.7}}' \
| jq '{eval_count, eval_duration, tok_s: (.eval_count / (.eval_duration/1000000000.0))}'
done
```
Example output:
```bash
{ "eval_count": 512, "eval_duration": 7573696632, "tok_s": 67.6 }
```
Notes

This image is optimized for MI50 (gfx906). It may work on other Vega 20 / gfx906 GPUs, but not guaranteed.
MI50 gives you 32 GB VRAM, which is useful for larger models, but performance is slower than modern GPUs.

License
MIT

