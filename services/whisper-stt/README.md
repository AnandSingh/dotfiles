# devserver-aks Whisper STT service

Private Speaches service backing the Vocalinux push-to-talk clients.

## Runtime

- Host: `devserver-aks`
- GPU: RTX 5080
- API: Speaches, OpenAI-compatible `/v1/audio/transcriptions`
- Model: `deepdml/faster-whisper-large-v3-turbo-ct2`
- Local bind: `127.0.0.1:8001`
- Tailnet URL: `https://devserver-aks.tail82c154.ts.net/stt`
- Container: rootless Podman Quadlet, pinned by image digest
- Model cache: `whisper-stt-models` Podman volume

The bearer key lives only in `~/.config/whisper-stt/env` with mode `0600`.
Never copy it into this repository. Start from `env.example`; in particular,
`WHISPER__TTL=-1` is the setting this pinned Speaches version recognizes for
indefinite GPU residency (`STT_MODEL_TTL` is ignored).

## Installed locations

```text
~/.config/containers/systemd/whisper-stt.container
~/.config/containers/systemd/whisper-stt-models.volume
~/.config/whisper-stt/env
~/.local/bin/whisper-stt-warmup
```

Templates for all non-secret files are in this directory. NVIDIA Container
Toolkit supplies the CDI device `nvidia.com/gpu=all`; rootless Podman also needs
`SecurityLabelDisable=true` on this Fedora host.

## Operations

```bash
systemctl --user status whisper-stt.service
journalctl --user -u whisper-stt.service -f
systemctl --user restart whisper-stt.service
podman ps --filter name=whisper-stt
nvidia-smi
tailscale serve status
```

The Quadlet runs the warm-up script after each start. A cold start takes roughly
45 seconds; warm test requests complete in roughly 0.4–0.5 seconds and use about
2.6 GiB of GPU memory.

## Client configuration

Use an OpenAI-compatible transcription client with:

```text
URL:      https://devserver-aks.tail82c154.ts.net/stt
Endpoint: /v1/audio/transcriptions
Model:    deepdml/faster-whisper-large-v3-turbo-ct2
```

Missing or incorrect bearer keys must return HTTP 403. Tailscale Serve is
tailnet-only; do not enable Funnel.
