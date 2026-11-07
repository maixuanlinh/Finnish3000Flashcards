# Audio and image provenance

The lesson text and illustrations are the existing canonical 3000 Finnish Words resources. Original images and metadata are retained unchanged in Resources. WebP files are distribution copies.

Finnish speech uses the published Piper `fi_FI-harri-medium` checkpoint. Its model card identifies a Finnish single-speaker dataset with a CC0 license and records fine-tuning from the English Lessac medium model. The publisher's voice repository is labelled MIT. The exact checkpoint checksum is recorded in the generated media manifest.

- https://huggingface.co/rhasspy/piper-voices/blob/main/fi/fi_FI/harri/medium/MODEL_CARD
- https://www.kaggle.com/bryanpark/finnish-single-speaker-speech-dataset
- https://huggingface.co/rhasspy/piper-voices

English speech uses `en_US-ljspeech-high`; its model card identifies the LJ Speech dataset as public domain. The exact checkpoint checksum is recorded in the generated manifest.

- https://huggingface.co/rhasspy/piper-voices/blob/main/en/en_US/ljspeech/high/MODEL_CARD
- https://keithito.com/LJ-Speech-Dataset/

The local generation environment uses Piper 1.8.0 (GPL-3.0-or-later), ONNX Runtime and FFmpeg. These executables, libraries, voice checkpoints and training data are not shipped inside the Android app or hosted media packs. The app receives generated MP3 recordings and optimized illustrations. Preserve this provenance with the media release; a blanket repository label does not replace the individual model cards and dataset information.

- https://github.com/OHF-Voice/piper1-gpl
- https://pypi.org/project/piper-tts/1.8.0/
