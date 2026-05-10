#!/data/data/com.termux/files/usr/bin/bash
# modules/setup-turnip.sh — GPU drivers Turnip/Zink para Adreno

setup_turnip() {
    echo "[gpu] Detectando GPU..."
    GPU_VENDOR=$(getprop ro.hardware.egl 2>/dev/null || echo "")
    CHIPSET=$(getprop ro.hardware.chipname 2>/dev/null || echo "")
    echo "[gpu] Vendor: ${GPU_VENDOR:-desconhecido}, Chipset: ${CHIPSET:-desconhecido}"

    if [[ "$GPU_VENDOR" == *"adreno"* ]] || [[ "$CHIPSET" == *"sm"* ]] || [[ "$CHIPSET" == *"kalama"* ]] || [[ "$CHIPSET" == *"taro"* ]] || [[ "$CHIPSET" == *"lahaina"* ]]; then
        echo "[gpu] Adreno detectado — instalando Turnip + Zink"
        pkg install -y mesa-zink mesa-vulkan-icd-freedreno vulkan-loader-android || \
            echo "[gpu] AVISO: Falha ao instalar drivers Turnip"
        GPU_TYPE="turnip"
    elif [[ "$CHIPSET" == *"exynos"* ]] || [[ "$GPU_VENDOR" == *"mali"* ]]; then
        echo "[gpu] Mali (Exynos) — sem Turnip, usando software rendering"
        pkg install -y mesa-zink mesa-vulkan-icd-swrast vulkan-loader-android || \
            echo "[gpu] AVISO: Falha ao instalar swrast"
        GPU_TYPE="swrast"
    else
        echo "[gpu] GPU desconhecida — tentando Turnip, fallback swrast"
        pkg install -y mesa-zink mesa-vulkan-icd-freedreno vulkan-loader-android || \
        pkg install -y mesa-zink mesa-vulkan-icd-swrast vulkan-loader-android || \
            echo "[gpu] AVISO: Nenhum driver GPU instalado"
        GPU_TYPE="fallback"
    fi

    echo "[gpu] Instalando mesa-utils no Arch..."
    run_in_arch "pacman -S --noconfirm mesa-utils" || true

    echo "[gpu] GPU configurado ($GPU_TYPE)"
}
