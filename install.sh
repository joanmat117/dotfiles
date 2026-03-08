#!/bin/bash

echo "🚀 Iniciando configuración automática de entorno..."

# 1. Evitar bloqueos de APT (esperar si el sistema está ocupado)
echo "🛠️ Verificando disponibilidad de paquetes..."
while sudo fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1; do
  echo "⏳ Esperando a que el sistema libere los bloqueos de instalación..."
  sleep 5
done

# 2. Instalar dependencias ignorando errores de repositorios externos (como Yarn)
# Usamos -y y --allow-unauthenticated para que no se detenga por errores de firmas
sudo apt-get update || true 
sudo apt-get install -y ripgrep fd-find --allow-unauthenticated

# 3. Instalar Neovim 0.10+ de forma silenciosa
if [ ! -d "/opt/nvim-linux-x86_64" ]; then
    echo "📦 Instalando Neovim estable..."
    curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
    sudo rm -rf /opt/nvim-linux-x86_64
    sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
    rm nvim-linux-x86_64.tar.gz
fi

# Crear enlace simbólico para que 'nvim' funcione siempre
sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim

# 4. Configurar AstroNvim
echo "🌌 Configurando AstroNvim..."
NVIM_DIR="$HOME/.config/nvim"
if [ ! -d "$NVIM_DIR" ]; then
    git clone --depth 1 https://github.com/AstroNvim/template "$NVIM_DIR"
    # Eliminar el .git del template para evitar conflictos
    rm -rf "$NVIM_DIR/.git"
fi

# 5. Mapear tus configuraciones desde Dotfiles
# GitHub clona los dotfiles en una carpeta específica, la buscamos:
DOTFILES_PATH=$(pwd)
mkdir -p "$NVIM_DIR/lua/plugins"

if [ -d "$DOTFILES_PATH/nvim/lua/plugins" ]; then
    cp -r "$DOTFILES_PATH/nvim/lua/plugins/"* "$NVIM_DIR/lua/plugins/"
    echo "✅ Configuración de plugins copiada."
fi

# 6. Configurar el shell (.bashrc) para persistencia
# Solo agregamos si no existen ya
if ! grep -q "nvim-linux-x86_64" ~/.bashrc; then
    echo 'export PATH="$PATH:/opt/nvim-linux-x86_64/bin"' >> ~/.bashrc
    echo "alias cls='clear'" >> ~/.bashrc
    echo "alias lvim='nvim'" >> ~/.bashrc
fi

# 7. Rust (opcional pero recomendado para Treesitter)
if ! command -v rustup &> /dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
fi

echo "✨ ¡Todo listo! Cuando abras nvim, se instalará el resto solo."
sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim
