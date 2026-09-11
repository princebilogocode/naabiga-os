#!/usr/bin/env bash
# Optimisation Android Studio : KVM pour l'émulateur, mémoire JVM Gradle, inotify
# SPDX-License-Identifier: GPL-3.0-or-later
set -uo pipefail
SUDO=""; [ "$(id -u)" -ne 0 ] && SUDO="sudo"

# Accélération matérielle de l'émulateur
if grep -qE 'vmx|svm' /proc/cpuinfo 2>/dev/null; then
  $SUDO apt-get install -y --no-install-recommends qemu-kvm libvirt-daemon-system bridge-utils >/dev/null 2>&1 || true
  $SUDO tee /etc/udev/rules.d/65-naabiga-kvm.rules >/dev/null <<'EOF'
KERNEL=="kvm", GROUP="kvm", MODE="0660"
EOF
fi

# Gradle : daemon, cache, mémoire (pour tous les utilisateurs via /etc/skel et comptes existants)
write_gradle_props() {
  local home="$1" owner="$2"
  install -d -o "$owner" -g "$owner" "$home/.gradle" 2>/dev/null || mkdir -p "$home/.gradle"
  if [ ! -f "$home/.gradle/gradle.properties" ]; then
    cat > "$home/.gradle/gradle.properties" <<'EOF'
# Naabiga OS : réglages Gradle par défaut
org.gradle.daemon=true
org.gradle.parallel=true
org.gradle.caching=true
org.gradle.configureondemand=true
org.gradle.jvmargs=-Xmx3g -XX:MaxMetaspaceSize=1g -XX:+HeapDumpOnOutOfMemoryError -Dfile.encoding=UTF-8
android.useAndroidX=true
kotlin.incremental=true
EOF
    chown "$owner:$owner" "$home/.gradle/gradle.properties" 2>/dev/null || true
  fi
}
write_gradle_props /etc/skel root
while IFS=: read -r name _ uid _ _ home _; do
  [ "$uid" -ge 1000 ] && [ "$uid" -lt 60000 ] && [ -d "$home" ] && write_gradle_props "$home" "$name"
done < /etc/passwd

echo "Optimisation Android Studio appliquée."
