#!/bin/bash
set -e

export HF_HUB_ENABLE_HF_TRANSFER=1
export HF_HUB_DISABLE_PROGRESS_BARS=1

echo ">>> Linking weights from Network Volume..."
rm -rf /MultiTalk/weights
ln -s /runpod-volume/multitalk_weights /MultiTalk/weights

echo ">>> Starting application..."
cd /
python handler.py
