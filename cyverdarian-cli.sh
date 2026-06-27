# CYVERDARIAN'S CUSTOM CTF FUNCTIONS (CORE LOGIC)
# ==============================================================================
# TRY KO LANG KUNG MAG SASAVE
# 2. Smart Hex XOR Decrypter (Pure Linux commands)
hexdec() {
    local hex_string=$1
    local input_key=$2
    local final_key=0

    # Kung ang input key ay napakahaba (Shared Secret), i-modulo 256 muna natin gamit ang bc
    if [ ${#input_key} -gt 5 ]; then
        final_key=$(echo "$input_key % 256" | bc)
    else
        final_key=$input_key
    fi

    # Simulan ang XOR decryption process gamit ang pure bash tools
    echo -n "$hex_string" | xxd -r -p | od -An -v -t u1 | tr -s ' ' '\n' | grep -v '^$' | while read -r num; do
        printf "\\$(printf '%03o' $((num ^ final_key)))"
    done
    echo ""
}

# ==============================================================================
# CYVERDARIAN'S CUSTOM CTF COMMANDS AND ALIASES
# ==============================================================================

export ROCKYOU="/mnt/c/Users/Marwin/Downloads/DICT/CTF/rockyou.txt"

# 1. MAIN HELP MENU (clhelp)
alias clhelp='echo -e "\n\e[1;32m[+] CYVERDARIAN MAIN MENU\e[0m" && \
echo "--------------------------------------------------------------------------------" && \
echo "Type any of the following commands to view specific category cheat sheets:" && \
echo -e "  \e[1;35mcchelp\e[0m  - Cryptography Tools (Ciphers, encoding, decoding, and hashing)" && \
echo -e "  \e[1;32mxhelp\e[0m   - Diffie-Hellman & XOR Tools (Custom Decryption Functions)" && \
echo -e "  \e[1;36mcfhelp\e[0m  - Digital Forensics (File analysis, hidden data, and metadata)" && \
echo -e "  \e[1;33mmhelp\e[0m   - Metadata Extraction & Decryption Guide (Advanced Parsing)" && \
echo -e "  \e[1;34mcnhelp\e[0m  - Network & Reconnaissance (Port scanning, SMB audits, and remote access)" && \
echo "--------------------------------------------------------------------------------" && \
echo -e "\e[1;33m[!] QUICK TERMINAL REMINDERS:\e[0m" && \
echo "  To edit this CLI script     : nano ~/cyverdarian-cli/cyverdarian-cli.sh" && \
echo "  To apply changes (Refresh)  : source ~/cyverdarian-cli/cyverdarian-cli.sh" && \
echo -e "  \e[1;31mTo exit back to Windows\e[0m     : Type \e[1;32mwin\e[0m or \e[1;32mclexit\e[0m" && \
echo "--------------------------------------------------------------------------------" && \
echo -e "  \e[1;34mthelp\e[0m  - CYVERDARIAN TOOLS HELP OPEN SOURCE" && \
echo "--------------------------------------------------------------------------------"'

alias win='exit'
alias clexit='exit'

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
echo -e "\e[1;33m[!] FOR ADVANCED XOR & DIFFIE-HELLMAN DECRYPTION:\e[0m" && \
echo -e "  Type \e[1;32mxhelp\e[0m to view usage for custom functions (dhxor & hexdec)." && \
echo "--------------------------------------------------------------------------------" && \
echo -e "\e[1;32m  [KALI BUILT-IN] HASH CRACKING WITH \$ROCKYOU:\e[0m" && \
echo "    1. Save hash to temporary file : echo '\''<hash_here>'\'' > /tmp/target.txt" && \
echo "    2. Crack MD5 with John       : john --format=Raw-MD5 --wordlist=\$ROCKYOU /tmp/target.txt" && \
echo "    3. Crack SHA-1 with John     : john --format=Raw-SHA1 --wordlist=\$ROCKYOU /tmp/target.txt" && \
echo "    4. Crack SHA-256 with John   : john --format=Raw-SHA256 --wordlist=\$ROCKYOU /tmp/target.txt" && \
echo "    5. Show cracked password     : john --show --format=<format_type> /tmp/target.txt" && \
echo "--------------------------------------------------------------------------------"'

# 3. NEW XOR SUB-MENU (xhelp)
alias xhelp='echo -e "\n\e[1;32m[✦] DIFFIE-HELLMAN & XOR HELP MENU\e[0m" && \
echo "DESCRIPTION: Custom functions for solving DH Key exchanges and automated XOR decryption." && \
echo "--------------------------------------------------------------------------------" && \
echo -e "\e[1;36m[FUNCTIONS DESCRIPTION & USAGE]\e[0m" && \
echo "  dhxor  : Calculates Shared Secret (A^b % p) % 256 to extract a 1-byte XOR key." && \
echo "  hexdec : Converts hex to raw data and decrypts it using a 1-byte key or a long Shared Secret." && \
echo "--------------------------------------------------------------------------------" && \
echo -e "\e[1;33m  SCENARIO 1: You have Public Key, Private Key, and Modulus\e[0m" && \
echo "    Usage 1 (Separate) : KEY=\$(dhxor \$A \$b \$p) -> Generates Key (e.g., 61)" && \
echo "                         hexdec \$enc \$KEY" && \
echo "    Usage 2 (Combined) : hexdec \$enc \$(dhxor \$A \$b \$p)" && \
echo "" && \
echo "    [REAL-WORLD EXAMPLE FOR SCENARIO 1]:" && \
echo "      A=9854453750...  b=253174800...  p=254918957... (long numbers)" && \
echo "      enc=\"4d545e527e697b465955624e0e5e4f0e49620404050f5b5b580b40\"" && \
echo "      * Mathematical Step: (A^b % p) % 256 resulting to Key = 61" && \
echo "      Command: hexdec \$enc \$(dhxor \$A \$b \$p)" && \
echo "" && \
echo -e "\e[1;33m  SCENARIO 2: You only have the Shared Secret (S) and Encrypted Hex (enc)\e[0m" && \
echo "    Smart Function     : hexdec \$enc \$S  (hexdec automatically performs modulo 256)" && \
echo "    Manual One-Liner   : KEY=\$(echo \"\$S % 256\" | bc) && echo -n \"\$enc\" | xxd -r -p | od -An -v -t u1 | tr -s '\'' '\'' '\''\n'\'' | grep -v '\''^\$'\'' | while read num; do printf \"\\\\\\\$(printf '\''%03o'\'' \((num ^ KEY)))\"; done; echo \"\"" && \
echo "" && \
echo "    [REAL-WORLD EXAMPLE FOR SCENARIO 2]:" && \
echo "      S=1611677189114812825149... (long Shared Secret number)" && \
echo "      enc=\"4d545e527e697b465955624e0e5e4f0e49620404050f5b5b580b40\"" && \
echo "      * Mathematical Step: S % 256 resulting to Key = 61" && \
echo "      Command: hexdec \$enc \$S" && \
echo "" && \
echo -e "\e[1;36m  [HOW TO DYNAMICALLY CALCULATE USING PYTHON FAST MATH PIPE]\e[0m" && \
echo "    If the variable names are changed (e.g., C, X, Y), follow this exact structure:" && \
echo -e "    \e[1;35mpow( BASE/PUBLIC_KEY , EXPONENT/PRIVATE_KEY , MODULUS_PRIME )\e[0m" && \
echo "" && \
echo "    Template Command   : echo \"print(pow(<BASE>, <EXPONENT>, <MODULUS>) % 256)\" | python3" && \
echo "    Real-World Example : echo \"print(pow(\$A, \$b, \$p) % 256)\" | python3" && \
echo "--------------------------------------------------------------------------------"'

# 4. DIGITAL FORENSICS SUB-MENU (cfhelp)
alias cfhelp='echo -e "\n\e[1;36m[✦] DIGITAL FORENSICS COMMAND LIST\e[0m" && \
echo "DESCRIPTION: Use this to analyze, dissect, and extract hidden data from files." && \
echo "WHEN TO USE: When you are given a mystery file, an image, or a corrupted file to find a hidden flag." && \
echo "--------------------------------------------------------------------------------" && \
echo "  File Type     : file file_name" && \
echo "  Find Flag     : strings file | grep -i clctf" && \
echo "  File Carving  : binwalk -e file --run-as=root" && \
echo "  Extract Gzip   : gunzip file_name.gz" && \
echo "  Extract Disk Image: binwalk -e file_name.dd --run-as=root" && \
echo "  Mount Disk Image  : sudo mount -o loop file_name.dd /mnt" && \
echo "  Open File/GUI : xdg-open file.png" && \
echo "  Metadata View : exiftool file.jpg" && \
echo "  Extract Hex   : exiftool -s3 -METADATA_FIELD file.jpg | xxd -r -p > OUTPUT_FILE" && \
echo "  Scan QR Code  : zbarimg IMAGE_FILE" && \
echo "  PNG LSB Stego  : zsteg IMAGE_FILE.png" && \
echo -e "  \e[1;33mFind File by Hash\e[0m: sha256sum files/* | grep \"<hash_here>\"" && \
echo "--------------------------------------------------------------------------------" && \
echo -e "\e[1;32m  [GUIDE: WHEN TO USE \"FIND FILE BY HASH\"]\e[0m" && \
echo "    - Run this when a challenge gives you a specific string of characters and tells" && \
echo "      you it is a \"legitimate key\", \"file fingerprint\", or \"valid checksum\"." && \
echo "    - Use this INSIDE remote SSH servers where your custom aliases do not exist." && \
echo "" && \
echo -e "\e[1;32m  [OTHER TERMS FOR \"DIGITAL FINGERPRINT\" IN CTFs]:\e[0m" && \
echo "    If you see any of these terms in the challenge description, it means the same thing:" && \
echo "    1. Checksum (e.g., SHA-256 Checksum, MD5 Checksum)" && \
echo "    2. File Hash / Cryptographic Hash" && \
echo "    3. Digital Signature / Verification Hash" && \
echo "    4. Integrity Hash / Authenticity Token" && \
echo "--------------------------------------------------------------------------------"'

# 5. ADVANCED METADATA & DECRYPTION MENU (mhelp)
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

# 6. NETWORK & RECONNAISSANCE SUB-MENU (cnhelp)
alias cnhelp='echo -e "\n\e[1;34m[✦] NETWORK & RECON COMMAND LIST\e[0m" && \
echo "DESCRIPTION: Use this to interact with remote network servers and exposed services." && \
echo "WHEN TO USE: When you have a target IP/Port and need to audit open network directories or printers." && \
echo "--------------------------------------------------------------------------------" && \
echo "  SMB List Shares : smbclient -L //IP_ADDRESS -p PORT -N" && \
echo "  SMB Connect     : smbclient //IP_ADDRESS/SHARE_NAME -p PORT -N" && \
echo "--------------------------------------------------------------------------------"'

# 7. OPE SOURCE TOOL
alias thelp='echo -e "\n\e[1;32m[+] CYVERDARIAN TOOLS HELP\e[0m" && \
echo "  VirusTotal  : https://www.virustotal.com (i-search ang hash dito)" && \
echo "--------------------------------------------------------------------------------"'
