# =======================================
# CYVERDARIAN'S CUSTOM CTF COMMANDS AND ALIASES
# ==========================================
# 1. MAIN HELP MENU (clhelp)
alias clhelp='echo -e "\n\e[1;32m[+]CYVERDARIAN MAIN MENU\e[0m" && \
echo "--------------------------------------------------" && \
echo "I-type ang mga sumusunod na commands para sa kategorya:" && \
echo -e "  \e[1;35mcchelp\e[0m  - Para sa mga command ng Cryptography" && \
echo -e "  \e[1;36mcfhelp\e[0m  - Para sa mga command ng Digital Forensics" && \
echo "--------------------------------------------------" && \
echo -e "\e[1;33m[!] TANDAAN MO ITONG TERMINAL COMMANDS:\e[0m" && \
echo "  Pang-edit ng code (Open Editor) : nano cyverdarian-cli.sh" && \
echo "  Pang-refresh ng code (Apply)    : source cyverdarian-cli.sh" && \
echo "--------------------------------------------------"'

# 2. CRYPTOGRAPHY SUB-MENU (cchelp)
alias cchelp='echo -e "\n\e[1;35m[✦] CRYPTOGRAPHY COMMAND LIST\e[0m" && \
echo "--------------------------------------------------" && \
echo "  Base64 Decode : echo -n '\''string'\'' | base64 -d" && \
echo "  Hex to ASCII  : echo '\''hex_string'\'' | xxd -r -p" && \
echo "  ROT13 Decode  : echo '\''text'\'' | tr '\''A-Za-z'\'' '\''N-ZA-Mn-za-m'\''" && \
echo "  MD5 Hash Gen  : echo -n '\''text'\'' | md5sum" && \
echo "--------------------------------------------------"'

# 3. DIGITAL FORENSICS SUB-MENU (cfhelp)
alias cfhelp='echo -e "\n\e[1;36m[✦] DIGITAL FORENSICS COMMAND LIST\e[0m" && \
echo "--------------------------------------------------" && \
echo "  File Type     : file nakatagong_file" && \
echo "  Find Flag     : strings file | grep -i clctf" && \
echo "  File Carving  : binwalk -e file --run-as=root" && \
echo "  Metadata View : exiftool file.jpg" && \
echo "--------------------------------------------------"'
