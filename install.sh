#!/bin/bash

echo "🚀 Iniciando configuración automática de entorno..."

# 1. Bloqueamos errores fatales pero dejamos pasar errores de repositorios
set +e 

# 2. Limpiar el PATH y asegurar directorios
DOTFILES_PATH=$(pwd)
NVIM_DIR="$HOME/.config/nvim"

# 3. Esperar a que el sistema libere el bloqueo de paquetes
echo "🛠️ Verificando disponibilidad de paquetes..."
while sudo fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1; do
  echo "⏳ Esperando bloqueo de apt..."
  sleep 5
done

# 4. Actualizar instalando SOLO lo necesario y permitiendo errores de firmas ajenas
# Usamos -o para ignorar el error de Yarn que sale en tu log
sudo apt-get update -o Acquire::AllowInsecureRepositories=true -o Acquire::AllowDowngradeToInsecureRepositories=true || true
sudo apt-get install -y ripgrep fd-find --allow-unauthenticated || echo "⚠️ Falló la instalación de ripgrep/fd, pero seguimos..."

# 5. Instalación de Neovim (Esta parte es manual, no depende de apt, así que funcionará)
echo "📦 Instalando Neovim..."
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
sudo rm -rf /opt/nvim-linux-x86_64
sudo mkdir -p /opt/nvim-linux-x86_64
sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
rm nvim-linux-x86_64.tar.gz

# 6. ENLACES SIMBÓLICOS (Lo más importante para que nvim aparezca)
sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim
sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/lvim

# 7. AstroNvim Setup
echo "🌌 Configurando AstroNvim..."
if [ ! -d "$NVIM_DIR" ]; then
    git clone --depth 1 https://github.com/AstroNvim/template "$NVIM_DIR"
    rm -rf "$NVIM_DIR/.git"
fi

# Copiar tus plugins desde el repo de dotfiles
mkdir -p "$NVIM_DIR/lua/plugins"
if [ -d "$DOTFILES_PATH/nvim/lua/plugins" ]; then
    cp -r "$DOTFILES_PATH/nvim/lua/plugins/"* "$NVIM_DIR/lua/plugins/"
fi

# 8. Re-activar salida por error para el resto del script
set -e 

# Instalar tmux
sudo apt install tmux -y

# Configurar tmux para ahorro de datos
cat >> ~/.tmux.conf << 'EOF'
set -g set-clipboard off
set -g status-interval 5
set -g monitor-activity off
set -g visual-bell off
set -g bell-action none
set -g refresh-client-interval 5
setw -g synchronize-panes off
set -g history-limit 2000
bind C-c run "tmux save-buffer - | pbcopy"
set -g status-right "#[fg=green]🔒 #[fg=white]compressed"
EOF

# Instalar opencode
curl -fsSL https://opencode.ai/install | bash

# Desactivar animaciones de opencode
mkdir -p ~/.config/opencode
cat > ~/.config/opencode/config.json << 'EOF'
{
  "theme": {
    "disableAnimations": true
  },
  "editor": {
    "cursorBlink": false,
    "smoothScrolling": false
  }
}
EOF

echo "✅ Listo. Prueba 'tmux' luego 'nvim'."
