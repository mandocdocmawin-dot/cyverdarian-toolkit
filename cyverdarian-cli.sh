# ==============================================================================
# CYVERDARIAN'S CUSTOM CTF COMMANDS AND ALIASES
# ==============================================================================

export ROCKYOU="/mnt/c/Users/Marwin/Downloads/DICT/CTF/rockyou.txt"

# 1. MAIN HELP MENU (clhelp)
alias clhelp='echo -e "\n\e[1;32m[+] CYVERDARIAN MAIN MENU\e[0m" && \
echo "--------------------------------------------------------------------------------" && \
echo "Type any of the following commands to view specific category cheat sheets:" && \
echo -e "  \e[1;35mcchelp\e[0m  - Cryptography Tools (Ciphers, encoding, decoding, and hashing)" && \
echo -e "  \e[1;36mcfhelp\e[0m  - Digital Forensics (File analysis, hidden data, and metadata)" && \
echo -e "  \e[1;33mmhelp\e[0m  - Metadata Extraction & Decryption Guide (Advanced Parsing)" && \
echo -e "  \e[1;34mcnhelp\e[0m  - Network & Reconnaissance (Port scanning, SMB audits, and remote access)" && \
echo "--------------------------------------------------------------------------------" && \
echo -e "\e[1;33m[!] QUICK TERMINAL REMINDERS:\e[0m" && \
echo "  To edit this CLI script     : nano ~/cyverdarian-cli/cyverdarian-cli.sh" && \
echo "  To apply changes (Refresh)  : source ~/cyverdarian-cli/cyverdarian-cli.sh" && \
echo "--------------------------------------------------------------------------------"'

# 2. CRYPTOGRAPHY SUB-MENU (cchelp)
alias cchelp='echo -e "\n\e[1;35m[✦] CRYPTOGRAPHY COMMAND LIST\e[0m" && \
echo "DESCRIPTION: Use this when dealing with encoded strings, hashes, or text ciphers." && \
echo "WHEN TO USE: When you find suspicious strings (like Base64), MD5 hashes, or need text generation." && \
echo "--------------------------------------------------------------------------------" && \
echo "  Base64 Decode : echo -n '\''string'\'' | base64 -d" && \
echo "  Hex to ASCII  : echo '\''hex_string'\'' | xxd -r -p" && \
echo "  ROT13 Decode  : echo '\''text'\'' | tr '\''A-Za-z'\'' '\''N-ZA-Mn-za-m'\''" && \
echo "  ASCII Repeat  : python3 -c '\''print(\"char\" * count)'\''" && \
echo "  RSA Decrypt   : openssl pkeyutl -decrypt -inkey PRIVATE_KEY -in ENCRYPTED_FILE -out OUTPUT_FILE" && \
echo "--------------------------------------------------------------------------------" && \
echo -e "\e[1;32m  [FUNCTION] DH XOR Key Finder:\e[0m" && \
echo "    Usage       : dhxor <A> <b> <p>" && \
echo "    Example     : dhxor \$A \$b \$p" && \
echo -e "\e[1;32m  [FUNCTION] Hex XOR Decrypter:\e[0m" && \
echo "    Usage       : hexdec <hex_string> <key>" && \
echo "    Example     : hexdec 4d545e527e697b465955624e0e5e4f0e49620404050f5b5b580b40 61" && \
echo "--------------------------------------------------------------------------------"
echo -e "\e[1;32m  [KALI BUILT-IN] HASH CRACKING WITH \$ROCKYOU:\e[0m" && \
echo "    1. Save hash to temporary file : echo '\''<hash_here>'\'' > /tmp/target.txt" && \
echo "    2. Crack MD5 with John       : john --format=Raw-MD5 --wordlist=\$ROCKYOU target.txt" && \
echo "    3. Crack SHA-1 with John     : john --format=Raw-SHA1 --wordlist=\$ROCKYOU target.txt" && \
echo "    4. Crack SHA-256 with John   : john --format=Raw-SHA256 --wordlist=\$ROCKYOU target.txt" && \
echo "    5. Show cracked password     : john --show --format=<format_type> target.txt" && \
echo "--------------------------------------------------------------------------------"'

# 3. DIGITAL FORENSICS SUB-MENU (cfhelp)
alias cfhelp='echo -e "\n\e[1;36m[✦] DIGITAL FORENSICS COMMAND LIST\e[0m" && \
echo "DESCRIPTION: Use this to analyze, dissect, and extract hidden data from files." && \
echo "WHEN TO USE: When you are given a mystery file, an image, or a corrupted file to find a hidden flag." && \
echo "--------------------------------------------------------------------------------" && \
echo "  File Type     : file file_name" && \
echo "  Find Flag     : strings file | grep -i clctf" && \
echo "  File Carving  : binwalk -e file --run-as=root" && \
echo "  Open File/GUI : xdg-open file.png" && \
echo "  Metadata View : exiftool file.jpg" && \
echo "  Extract Hex   : exiftool -s3 -METADATA_FIELD file.jpg | xxd -r -p > OUTPUT_FILE" && \
echo "  Scan QR Code  : zbarimg IMAGE_FILE" && \
echo "--------------------------------------------------------------------------------"'

# 4. ADVANCED METADATA & DECRYPTION MENU (metaviewhelp)
alias mhelp='echo -e "\n\e[1;33m[✦] METADATA EXTRACTION & DECRYPTION GUIDE\e[0m" && \
echo "DESCRIPTION: Advanced pipeline for dumping hidden encrypted data/keys from image metadata." && \
echo "--------------------------------------------------------------------------------" && \
echo -e "\e[1;36mSTEP 1: Identify the Target Field (Run '\''exiftool file.jpg'\'' first)\e[0m" && \
echo "  Select a command below depending on which tag holds the long Hex/Base64 string:" && \
echo "  Comment     : exiftool -s3 -Comment file.jpg | xxd -r -p > output.key" && \
echo "  Description : exiftool -s3 -Description file.jpg | xxd -r -p > output.key" && \
echo "  Artist      : exiftool -s3 -Artist file.jpg | xxd -r -p > output.key" && \
echo "  Copyright   : exiftool -s3 -Copyright file.jpg | xxd -r -p > output.key" && \
echo "  Title       : exiftool -s3 -Title file.jpg | xxd -r -p > output.key" && \
echo "  Software    : exiftool -s3 -Software file.jpg | xxd -r -p > output.key" && \
echo "" && \
echo -e "\e[1;36mSTEP 2: Decrypt using the Extracted Key\e[0m" && \
echo "  [Option A: RSA Private Key found (Starts with MIIEv...)]" && \
echo "    If the key is a raw body, manually add standard PEM headers before running:" && \
echo "    Command: openssl pkeyutl -decrypt -inkey private.key -in file.enc -out flag.txt" && \
echo "" && \
echo "  [Option B: AES Password/Symmetric String found]" && \
echo "    If the metadata yielded a passphrase/password instead of an RSA key:" && \
echo "    Command: openssl enc -d -aes-256-cbc -in file.enc -out flag.txt" && \
echo "--------------------------------------------------------------------------------"'

# 5. NETWORK & RECONNAISSANCE SUB-MENU (cnhelp)
alias cnhelp='echo -e "\n\e[1;34m[✦] NETWORK & RECON COMMAND LIST\e[0m" && \
echo "DESCRIPTION: Use this to interact with remote network servers and exposed services." && \
echo "WHEN TO USE: When you have a target IP/Port and need to audit open network directories or printers." && \
echo "--------------------------------------------------------------------------------" && \
echo "  SMB List Shares : smbclient -L //IP_ADDRESS -p PORT -N" && \
echo "  SMB Connect     : smbclient //IP_ADDRESS/SHARE_NAME -p PORT -N" && \
echo "--------------------------------------------------------------------------------"'
