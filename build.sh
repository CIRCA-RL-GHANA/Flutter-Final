#!/bin/bash
git clone https://github.com/flutter/flutter.git --depth 1
export PATH="$PATH:`pwd`/flutter/bin"
flutter doctor
flutter build web
