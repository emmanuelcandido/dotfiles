#!/data/data/com.termux/files/usr/bin/bash
# modules/setup-turnip.sh — GPU drivers Turnip/Zink para Adreno

setup_turnip() {
    echo "[gpu] Instalando drivers GPU..."

    # Detecta GPU
    GPU_VENDOR=$(getprop ro.hardware.egl 2>/dev/null || echo "")
    CHIPSET=$(getprop ro.hardware.chipname 2>/dev/null || echo "")

    if [[ "$GPU_VENDOR" == *"adreno"* ]] || [[ "$CHIPSET" == *"sm"* ]] || [[ "$CHIPSET" == *"kalama"* ]] || [[ "$CHIPSET" == *"taro"* ]] || [[ "$CHIPSET" == *"lahaina"* ]]; then
        echo "[gpu] Adreno detectado — instalando Turnip + Zink"
        pkg install -y mesa-zink mesa-vulkan-icd-freedreno vulkan-loader-android > /dev/null 2>&1
        GPU_TYPE="turnip"
    elif [[ "$CHIPSET" == *"exynos"* ]] || [[ "$GPU_VENDOR" == *"mali"* ]]; then
        echo "[gpu] Mali (Exynos) — sem Turnip, usando Zink software"
        pkg install -y mesa-zink mesa-vulkan-icd-swrast vulkan-loader-android > /dev/null 2>&1
        GPU_TYPE="swrast"
    else
        echo "[gpu] GPU desconhecida — tentando Turnip, fallback swrast"
        pkg install -y mesa-zink mesa-vulkan-icd-freedreno vulkan-loader-android > /dev/null 2>&1 || \
        pkg install -y mesa-zink mesa-vulkan-icd-swrast vulkan-loader-android > /dev/null 2>&1
        GPU_TYPE="fallback"
    fi

    # Instala mesa-utils dentro do proot
    run_in_arch "pacman -S --noconfirm mesa-utils > /dev/null 2>&1" || true

    echo "[gpu] GPU configurado ($GPU_TYPE)"
}
