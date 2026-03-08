#!/bin/bash

echo "🚀 Iniciando instalación de Dotfiles personalizada..."

# 1. Definir rutas útiles
DOTFILES_DIR=$(pwd)
NVIM_CONFIG_DIR="$HOME/.config/nvim"

# 2. Instalar Neovim 0.10+ (Binario oficial estable)
echo "📦 Instalando Neovim..."
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
sudo rm -rf /opt/nvim-linux-x86_64
sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz

# Hacer que el comando nvim esté disponible siempre
sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim

# 3. Instalar Rust y Cargo (Necesario para herramientas como fd-find y ripgrep)
echo "🦀 Instalando Rust..."
if ! command -v rustup &> /dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
fi

# 4. Instalar dependencias del sistema (Ripgrep y FD son vitales para AstroNvim)
echo "🛠️ Instalando dependencias de sistema (ripgrep, fd, node)..."
sudo apt-get update
sudo apt-get install -y ripgrep fd-find nodejs npm

# 5. Configurar AstroNvim
echo "🌌 Configurando AstroNvim..."
# Limpiar configuraciones viejas si existen
rm -rf "$NVIM_CONFIG_DIR"

# Clonar el template oficial de AstroNvim
git clone --depth 1 https://github.com/AstroNvim/template "$NVIM_CONFIG_DIR"
rm -rf "$NVIM_CONFIG_DIR/.git"

# 6. Mapear tus archivos personalizados desde el repo de Dotfiles
echo "📂 Copiando archivos de configuración de nvim..."
mkdir -p "$NVIM_CONFIG_DIR/lua/plugins"

# Copiamos el contenido de tu carpeta 'nvim' del repo a la config real
if [ -d "$DOTFILES_DIR/nvim/lua/plugins" ]; then
    cp -r "$DOTFILES_DIR/nvim/lua/plugins/"* "$NVIM_CONFIG_DIR/lua/plugins/"
    echo "✅ Plugins personalizados copiados."
else
    echo "⚠️ No se encontró la carpeta nvim/lua/plugins en los dotfiles."
fi

# 7. Agregar aliases útiles al .bashrc
echo "⌨️ Configurando Aliases..."
{
    echo "export PATH=\$PATH:/opt/nvim-linux-x86_64/bin"
    echo "alias lvim='nvim'"
    echo "alias cls='clear'"
} >> "$HOME/.bashrc"

echo "✨ ¡Proceso completado! Abre 'nvim' para que se instalen los plugins automáticamente."
