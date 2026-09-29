#!/bin/bash
set -e

VOL=/runpod-volume/multitalk_weights

export HF_HUB_DISABLE_PROGRESS_BARS=1

echo ">>> DIAG: τι βλέπει ο worker"
ls -la /runpod-volume 2>&1 | head -20 || true
echo "mount:"; mount | grep -i runpod || echo "(κανένα mount με runpod)"

VOL_OK=1
for d in Wan2.1-I2V-14B-480P chinese-wav2vec2-base MeiGen-MultiTalk; do
  if [ ! -d "$VOL/$d" ]; then
    echo "WARNING: λείπει ο φάκελος $VOL/$d"
    VOL_OK=0
  fi
done

if [ "$VOL_OK" = "1" ]; then
  echo ">>> Volume βρέθηκε: offline mode + linking weights"
  export HF_HUB_OFFLINE=1
  export TRANSFORMERS_OFFLINE=1
  unset HF_HUB_ENABLE_HF_TRANSFER

  rm -rf /MultiTalk/weights
  ln -sfn "$VOL" /MultiTalk/weights

  echo ">>> Έλεγχος κρίσιμων αρχείων"
  for f in \
    Wan2.1-I2V-14B-480P/diffusion_pytorch_model.safetensors.index.json \
    Wan2.1-I2V-14B-480P/multitalk.safetensors \
    Wan2.1-I2V-14B-480P/config.json \
    Wan2.1-I2V-14B-480P/diffusion_pytorch_model-00001-of-00007.safetensors \
    chinese-wav2vec2-base/config.json \
    chinese-wav2vec2-base/pytorch_model.bin \
    MeiGen-MultiTalk/quant_models/quant_model_int8_FusionX.safetensors; do
    if [ -f "/MultiTalk/weights/$f" ]; then echo "OK   $f"; else echo "MISSING $f"; fi
  done
else
  echo ">>> WARNING: το volume ΔΕΝ είναι διαθέσιμο (test pod;). Online mode, δεν αγγίζω το /MultiTalk/weights."
  export HF_HUB_ENABLE_HF_TRANSFER=1
fi

echo ">>> Starting application..."
cd /
exec python -u handler.py
