# Voice dictation

## Goal

Provide a free, self-hosted dictation experience similar to Wispr Flow:

1. Hold a global push-to-talk key.
2. Speak naturally in any application.
3. Release the key.
4. Receive punctuated text in the field that was focused before recording.

The client must feel like a desktop input tool, not a terminal workflow. It must
work in Sway/Wayland and be reusable from other laptops without running a large
model locally.

## Current status

Deployed on 2026-11-25. Hold `F10` and release it to transcribe and paste. Fn
alone cannot be bound because keyboard firmware does not expose it to Linux.
Vocalinux starts as a user service, keeps no local speech model, and uses
the authenticated tailnet endpoint at
`https://devserver-aks.tail82c154.ts.net/stt`.

The tested turbo model stays warm on the RTX 5080 at about 2.6 GiB VRAM. Warm
synthetic requests complete in roughly 0.4–0.5 seconds; the complete Vocalinux
record/upload/transcribe cycle returned a 6.7-second sample in 0.47 seconds.
The API rejects missing keys with HTTP 403 and is not exposed through Tailscale
Funnel, the LAN, or the public internet.

## Chosen architecture

```text
laptop microphone
  -> Vocalinux desktop client
  -> HTTPS inside Tailscale
  -> Speaches on devserver-aks
  -> Whisper on the RTX 5080
  -> transcript returned to Vocalinux
  -> wl-clipboard + wtype into the focused application
```

- **Client:** [Vocalinux](https://github.com/VocaHQ/vocalinux), using its remote
  OpenAI-compatible transcription backend. It supports Fedora, Sway, Wayland,
  `wtype`, push-to-talk, local VAD, and custom vocabulary.
- **Server:** [Speaches](https://github.com/speaches-ai/speaches), exposing
  `POST /v1/audio/transcriptions` from a persistent rootless container.
- **Network:** Tailscale Serve provides tailnet-only HTTPS. Speaches remains
  bound to server loopback and also requires a random bearer key.
- **Initial host:** `devserver-aks`. Its RTX 5080 has enough capacity and is not
  occupied by the always-on LLM workloads currently filling `telisky-ai`.
- **Possible later host:** `telisky-ai`, only after enough VRAM is reserved for
  transcription or a smaller model is accepted.

No transcription port should be exposed to the public internet or ordinary LAN.
Audio is transient and should not be retained by the server.

## Model policy

The selected model is `deepdml/faster-whisper-large-v3-turbo-ct2` using
float16 on the RTX 5080. It remains loaded (`WHISPER__TTL=-1`) and an automatic
warm-up request runs whenever the service starts.

Vocalinux's custom dictionary should include terms such as Telisky, RC500,
OpenWrt, OpenAMP, Petalinux, LoRaWAN, Netconf, Hermes, Nexus, Forgejo, and the
active product names. Speaches receives this vocabulary through faster-whisper
hotwords rather than a prior-transcript prompt, reducing repetition on short audio.

## Implementation phases

### 0. Remove obsolete experiments — completed

The disabled laptop-local `voice-dev`, OpenAI-backed `pi-voice`, scp-per-request
`voice-devserver`, standalone Whisper wrappers/models, and unused Sway bindings
were removed. The obsolete `@juicesharp/rpiv-voice` package and its F9/Alt-key
shortcuts, footer status, and text-correction extensions were also removed from
Pi on both the laptop and `devserver-aks`. Global F10 through Vocalinux is the
sole dictation path; no competing voice daemon or local speech model remains.

The old `freeflow-stt` container on `telisky-ai` is decommissioned but its
service definition may be retained as a reference for a possible later move.

### 1. Maintenance gate for devserver-aks — completed

The approved reboot restored matching NVIDIA `620.70.06` userspace and kernel
modules under kernel `7.3.4`. Tmux-resurrect restored both session layouts as
shells; running Pi processes did not survive, as expected.

### 2. Server service — completed

NVIDIA Container Toolkit supplies rootless Podman CDI access. A digest-pinned
Speaches Quadlet binds only to `127.0.0.1:8001`, uses a mode-0600 random bearer
key, persists its model in a named volume, restarts automatically, and warms the
model after every start. Tailscale Serve proxies the private `/stt` path.
Non-secret deployment templates and operating instructions are in
`services/whisper-stt/`.

Client endpoint:

```text
https://devserver-aks.tail82c154.ts.net/stt/v1/audio/transcriptions
```

### 3. Fedora/Sway client — completed

Vocalinux `0.18.6` is installed from its checksum-verified Fedora RPM and runs
as `vocalinux.service`. It uses `wtype`, keeps its overlay disabled to preserve
focus, and stores its API key only in the mode-0600 machine-local config. Sway
owns a repeat-safe `F10` press/release binding. Sound feedback is disabled; an
animated Waybar waveform shows microphone startup, listening, and transcription.
A user-owned compatibility overlay gives external D-Bus activation true
push-to-talk semantics, enables Speaches hotwords and VAD, guards against
pathological whole-phrase repetition, and pre-initializes the PortAudio device
context. The context avoids repeated two-second device enumeration, while the
actual microphone stream still opens only for F10 and closes on release. Tested
idle-to-recording latency is about 0.1 seconds. Silero neural VAD rejects
non-speech room noise; speech from a nearby TV still counts as speech, so
release F10 when not actively dictating.

### 4. Other laptops

Install Vocalinux on other Linux laptops and reuse the authenticated Tailscale
endpoint. Other operating systems may use any client that supports the standard
OpenAI `/v1/audio/transcriptions` endpoint. Each device must be a permitted
Tailscale member and hold the API key locally.

## Acceptance criteria

- Hold, speak, release, and paste works in Ghostty, Chrome, editors, and chat.
- The original target window retains focus.
- Waybar clearly distinguishes yellow microphone startup, a red listening
  waveform, and a purple transcription waveform.
- No terminal interaction is required.
- A normal short utterance returns quickly enough to feel interactive.
- Technical product names are transcribed reliably.
- The model is warm after service startup.
- The endpoint is unreachable outside the tailnet and rejects missing keys.
- No local Whisper model, duplicate voice daemon, or old voice hotkey remains.
