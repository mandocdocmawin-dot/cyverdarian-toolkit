# ==============================================================================
# CYVERDARIAN'S CUSTOM CTF COMMANDS AND ALIASES
# ==============================================================================

# 1. MAIN HELP MENU (clhelp)
alias clhelp='echo -e "\n\e[1;32m[+] CYVERDARIAN MAIN MENU\e[0m" && \
echo "--------------------------------------------------------------------------------" && \
echo "Type any of the following commands to view specific category cheat sheets:" && \
echo -e "  \e[1;35mcchelp\e[0m  - Cryptography Tools (Ciphers, encoding, decoding, and hashing)" && \
echo -e "  \e[1;36mcfhelp\e[0m  - Digital Forensics (File analysis, hidden data, and metadata)" && \
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
echo "  MD5 Hash Gen  : echo -n '\''text'\'' | md5sum" && \
echo "  ASCII Repeat  : python3 -c '\''print(\"char\" * count)'\''" && \
echo "--------------------------------------------------------------------------------"'

# 3. DIGITAL FORENSICS SUB-MENU (cfhelp)
alias cfhelp='echo -e "\n\e[1;36m[✦] DIGITAL FORENSICS COMMAND LIST\e[0m" && \
echo "DESCRIPTION: Use this to analyze, dissect, and extract hidden data from files." && \
echo "WHEN TO USE: When you are given a mystery file, an image, or a corrupted file to find a hidden flag." && \
echo "--------------------------------------------------------------------------------" && \
echo "  File Type     : file file_name" && \
echo "  Find Flag     : strings file | grep -i clctf" && \
echo "  File Carving  : binwalk -e file --run-as=root" && \
echo "  Metadata View : exiftool file.jpg" && \
echo "--------------------------------------------------------------------------------"'

# 4. NETWORK & RECONNAISSANCE SUB-MENU (cnhelp)
alias cnhelp='echo -e "\n\e[1;34m[✦] NETWORK & RECON COMMAND LIST\e[0m" && \
echo "DESCRIPTION: Use this to interact with remote network servers and exposed services." && \
echo "WHEN TO USE: When you have a target IP/Port and need to audit open network directories or printers." && \
echo "--------------------------------------------------------------------------------" && \
echo "  SMB List Shares : smbclient -L //IP_ADDRESS -p PORT -N" && \
echo "  SMB Connect     : smbclient //IP_ADDRESS/SHARE_NAME -p PORT -N" && \
echo "--------------------------------------------------------------------------------"'
