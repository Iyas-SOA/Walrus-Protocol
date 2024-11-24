#!/bin/bash

echo -e "\e[1;34m
  █████████      ███████      █████████ 
  ██     ██    ███     ███   ███     ███
  ██          ███       ███  ███     ███
  █████████   ███       ███  ███████████
         ██   ███       ███  ███     ███
  ██     ██    ███     ███   ███     ███
  █████████      ███████    █████   █████                
==============================================
    Telegram Channel  : @schoolofairdrop              
    Telegram Group    : @soadiscussion         
==============================================\e[0m"

# Menampilkan pilihan kategori
echo "Dimana Kamu menjalankan Bot ini?"
echo "1. VPS/LINUX"
echo "2. TERMUX"
read -p "Tentukan pilihanmu: " choice

if [[ "$choice" != "1" && "$choice" != "2" ]]; then
    echo "Pilihan tidak valid. Silakan masukkan 1 atau 2."
    exit 1
fi

# Mengunduh dan menjalankan skrip asclogo.sh
curl -s https://raw.githubusercontent.com/Iyas-SOA/Files/refs/heads/main/Logo%20SOA.sh | bash
sleep 5

# Fungsi untuk cek dan install alat yang diperlukan
check_and_install() {
    if ! command -v $1 &> /dev/null; then
        echo "$1 is not installed. Installing $1..."
        if [ "$1" == "git" ]; then
            if [ "$choice" == "2" ]; then
                pkg install -y git
            else
                sudo apt update && sudo apt install -y git
            fi
        elif [ "$1" == "npm" ]; then
            if [ "$choice" == "2" ]; then
                pkg install -y npm
            else
                sudo apt update && sudo apt install -y npm
            fi
        elif [ "$1" == "node" ]; then
            if [ "$choice" == "2" ]; then
                pkg install -y nodejs
            else
                sudo apt update && sudo apt install -y nodejs
            fi
        elif [ "$1" == "screen" ]; then
            if [ "$choice" == "2" ]; then
                echo "Screen is not available on Termux. Running without it."
            else
                sudo apt update && sudo apt install -y screen
            fi
        else
            echo "Unknown package: $1"
            exit 1
        fi
    else
        echo "$1 is already installed."
    fi
}

# Cek dan install alat-alat yang dibutuhkan
check_and_install git
check_and_install npm
check_and_install node

# Direktori tujuan
DIRECTORY="$HOME/walrush-testnet"

# Cek apakah direktori sudah ada
if [ -d "$DIRECTORY" ]; then
    echo "Directory $DIRECTORY already exists. Deleting it..."
    rm -rf "$DIRECTORY"  # Menghapus direktori jika sudah ada
fi

# Clone ulang repository
echo "Cloning the repository..."
git clone https://github.com/alexswanFantom/walrush-testnet.git "$DIRECTORY"

# Pindah ke direktori
cd "$DIRECTORY" || { echo "Failed to access $DIRECTORY"; exit 1; }

# Install npm dependencies
echo "Installing npm dependencies..."
npm install

# Menyiapkan array untuk private keys
PRIVATE_KEYS=()

while true; do
    read -p "Submit private key (ketik 'exit' untuk lanjut): " PRIVATE_KEY
    if [ "$PRIVATE_KEY" == "exit" ]; then
        break
    fi
    PRIVATE_KEYS+=("$PRIVATE_KEY")  # Menyimpan private key ke dalam array
done

# Menyimpan private keys ke file accounts.js
echo "export const privateKey = [" > "app/accounts/accounts.js"
for key in "${PRIVATE_KEYS[@]}"; do
    echo "\"$key\"," >> "app/accounts/accounts.js"
done
# Menghapus koma terakhir dan menambahkan penutup array
sed -i '$ s/,$//' "app/accounts/accounts.js"
echo "];" >> "app/accounts/accounts.js"

echo "Private keys have been added to app/accounts/accounts.js."

# Menjalankan BOT
if [ "$choice" == "2" ]; then
    echo "Menjalankan BOT..."
    node index.js
else
    echo "Menjalankan BOT dengan screen..."
    screen -dmS walrush node index.js  # Menjalankan node dalam screen detached mode
    echo "Bot sudah dijalankan. Cek menggunakan 'screen -r walrush'"
fi
