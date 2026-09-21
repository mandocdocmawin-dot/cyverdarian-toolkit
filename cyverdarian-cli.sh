# CYVERDARIAN'S CUSTOM CTF FUNCTIONS (CORE LOGIC)
# ==============================================================================
urlcheck() {
    if [ -z "$1" ]; then
        echo "Paano gamitin: urlcheck \"URL\""
        echo "Halimbawa: urlcheck \"https://www.google.com\""
        return 1
    fi

    # Gagamit ng inline Python na may built-in urllib para sa mabilis at ligtas na check
    python3 -c "
import sys
import urllib.request
import urllib.parse
from urllib.error import URLError, HTTPError
import ssl

url = sys.argv[1]

# 1. Structural Validation
parsed_url = urllib.parse.urlparse(url)
if not parsed_url.scheme or not parsed_url.netloc:
    print('[-] Error: Hindi valid ang format ng URL.')
    sys.exit(1)

if parsed_url.scheme != 'https':
    print('[-] WARNING: Hindi gumagamit ng HTTPS! Delikado at hindi encrypted ang koneksyon.')

# 2. Connection and SSL/TLS Validation
print(f'[+] Sinusuri ang koneksyon at sertipiko para sa: {parsed_url.netloc}...')

try:
    # Gumawa ng request na may timeout na 5 segundo
    req = urllib.request.Request(
        url,
        headers={'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) CyverdarianCLI/1.0'}
    )
    with urllib.request.urlopen(req, timeout=5) as response:
        print(f'[+] Ligtas ang koneksyon! Valid ang SSL certificate (Status Code: {response.status}).')

except HTTPError as e:
    # Kung buhay ang server pero nag-error ang page (e.g., 404, 403), valid pa rin ang SSL
    print(f'[+] Ligtas ang koneksyon! Valid ang SSL ngunit nag-respond ang server ng Error Code: {e.code}')

except URLError as e:
    # Sinasala kung SSL error ang dahilan ng pagkabigo
    if isinstance(e.reason, ssl.SSLError):
        print('[-] DANGER: SSL/TLS Certificate Verification Failed! Maaaring peke o expired ang sertipiko.')
    else:
        print(f'[-] Error: Hindi maabot ang server. Dahilan: {e.reason}')
except Exception as e:
    print(f'[-] Error: May naganap na hindi inaasahang problema: {e}')
" "$1"
}

a1z26() {
    if [ -z "$1" ]; then
        echo "Paano gamitin: a1z26 \"NUMBERS\""
        echo "Halimbawa: a1z26 \"11-1-12-9\" o a1z26 \"11 1 12 9\""
        return 1
    fi

    # Gagamit ng maikling Python one-liner para sa kalkulasyon
    python3 -c "
import sys
tokens = sys.argv[1].replace('-', ' ').split()
try:
    print('Decoded: ' + ''.join(chr(64 + int(t)) if 1 <= int(t) <= 26 else f'[{t}?]' for t in tokens))
except ValueError:
    print('Error: Siguraduhing mga numero lamang ang nilalaman ng cipher.')
" "$1"
}

# 3. Caesar Cipher Brute-Forcer (subok LAHAT ng 26 shifts, kasama na ang ROT13)
caesar() {
    if [ -z "$1" ]; then
        echo "Paano gamitin: caesar \"TEXT\""
        echo "Halimbawa: caesar \"wpjvJAM{jhlzhy_k3jy9wa3k_890k2379}\""
        return 1
    fi

    python3 -c "
import sys
s = sys.argv[1]
for shift in range(26):
    out = ''
    for c in s:
        if c.isalpha():
            base = ord('A') if c.isupper() else ord('a')
            out += chr((ord(c)-base+shift)%26+base)
        else:
            out += c
    print(f'{shift:2d}: {out}')
" "$1"
}

# 4. CTF String Identifier (ctfid) - hindi ginamit ang pangalang "identify"
#    dahil kinukuha yun ng /usr/bin/identify (ImageMagick) sa Kali.
ctfid() {
    if [ -z "$1" ]; then
        echo "Paano gamitin: ctfid \"STRING\""
        echo "Halimbawa: ctfid \"5f4dcc3b5aa765d61d8327deb882cf99\""
        return 1
    fi

    python3 -c "
import sys, re, base64

s = sys.argv[1].strip()
found = []

# --- 1. HASH IDENTIFICATION (base sa haba at hex charset) ---
if re.fullmatch(r'[a-fA-F0-9]+', s):
    length = len(s)
    hash_map = {
        32:  'MD5 / NTLM (parehong 32 hex chars)',
        40:  'SHA-1',
        56:  'SHA-224',
        64:  'SHA-256',
        96:  'SHA-384',
        128: 'SHA-512',
        8:   'CRC32',
    }
    if length in hash_map:
        found.append(f'[HASH] Posibleng {hash_map[length]} ({length} hex characters)')
    if length % 2 == 0:
        found.append(f'[HEX] Pwede ring plain Hex-encoded data ({length} chars) -> try: echo \"{s}\" | xxd -r -p')

# --- 2. BASE64 CHECK ---
if re.fullmatch(r'[A-Za-z0-9+/]+={0,2}', s) and len(s) % 4 == 0:
    try:
        decoded = base64.b64decode(s)
        preview = decoded[:40]
        found.append(f'[BASE64] Valid Base64! Preview ng decoded: {preview}')
    except Exception:
        pass

# --- 3. URL-SAFE BASE64 (JWT parts, atbp) ---
if re.fullmatch(r'[A-Za-z0-9_-]+', s) and not re.fullmatch(r'[a-fA-F0-9]+', s):
    if '.' in sys.argv[1] and sys.argv[1].count('.') == 2:
        found.append('[JWT] Mukhang JSON Web Token (3 parts na pinaghihiwalay ng tuldok)')

# --- 4. BINARY CHECK ---
if re.fullmatch(r'[01\s]+', s) and len(s.replace(' ', '')) % 8 == 0:
    found.append('[BINARY] Puro 0 at 1 -> try: echo \"'+s+'\" | perl -lpe \'\$_=pack(\"B*\",\$_)\'')

# --- 5. PEM / RSA KEY CHECK ---
if 'BEGIN' in s and ('PRIVATE KEY' in s or 'PUBLIC KEY' in s or 'CERTIFICATE' in s):
    found.append('[PEM/RSA] Mukhang RSA Key o Certificate (PEM format)')

# --- 6. URL ENCODING CHECK ---
if re.search(r'%[0-9a-fA-F]{2}', s):
    found.append('[URL-ENCODED] May %XX patterns -> try: python3 -c \"import urllib.parse,sys; print(urllib.parse.unquote(sys.argv[1]))\" \"' + s + '\"')

# --- 7. A1Z26 CHECK (numbers separated by dash/space, all 1-26) ---
tokens = re.split(r'[-\s]+', s)
if all(t.isdigit() and 1 <= int(t) <= 26 for t in tokens if t) and len(tokens) > 1:
    found.append('[A1Z26] Mukhang A1Z26 cipher (mga numero 1-26) -> try: a1z26 \"'+s+'\"')

# --- 8. PLAIN ALPHA (posibleng Caesar/ROT/Vigenere/plain text) ---
if re.fullmatch(r'[A-Za-z0-9_{}]+', s) and not re.fullmatch(r'[a-fA-F0-9]+', s) and any(c.isalpha() for c in s):
    found.append('[TEXT/CIPHER] Mukhang plain text o naka-cipher (Caesar/ROT/Substitution) -> try: caesar \"'+s+'\"')

# --- RESULT OUTPUT ---
if found:
    print(f'[*] Sinuri: {s[:60]}{\"...\" if len(s) > 60 else \"\"}')
    print('-' * 70)
    for f in found:
        print(f)
    print('-' * 70)
    print('[!] Note: Maaaring maraming layer ang encoding (e.g. Base64 -> Base64 -> Caesar).')
    print('    Subukan muna ang unang match, tapos i-ctfid() ulit ang resulta.')
else:
    print('[-] Hindi matukoy ang format. Baka custom cipher o binary file ito.')
    print('    Subukan: file <filename> (kung file), o i-check gamit CyberChef Magic Wand.')
" "$1"
}


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

alias clhelp='echo -e "\n\e[1;32m[+] CYVERDARIAN MAIN MENU\e[0m" && \
echo "--------------------------------------------------------------------------------" && \
echo "Type any of the following commands to view specific category cheat sheets:" && \
echo -e "  \e[1;35mfhelp\e[0m   - Custom Functions (urlcheck, a1z26, hexdec, caesar, ctfid standalone usages)" && \
echo -e "  \e[1;35mcchelp\e[0m  - Cryptography Tools (Ciphers, encoding, decoding, and hashing)" && \
echo -e "  \e[1;32mxhelp\e[0m   - Diffie-Hellman & XOR Tools (Custom Decryption Functions)" && \
echo -e "  \e[1;36mcfhelp\e[0m  - Digital Forensics (File analysis, hidden data, and metadata)" && \
echo -e "  \e[1;34mshelp\e[0m   - Steganography Tools (Hidden data in images, audio, and extraction)" && \
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

# 1. MAIN HELP MENU (clhelp)
# CUSTOM FUNCTIONS HELP MENU (fhelp)
alias fhelp='echo -e "\n\e[1;35m[🛠️] CYVERDARIAN CUSTOM FUNCTIONS CHEATSHEET\e[0m" && \
echo "DESCRIPTION: List of interactive bash/python functions loaded into your core logic." && \
echo "--------------------------------------------------------------------------------" && \
echo -e "  \e[1;32m1. URL Security Scanner (urlcheck)\e[0m" && \
echo "     Usage      : urlcheck \"<URL>\"" && \
echo "     Example    : urlcheck \"https://www.google.com\"" && \
echo "     Purpose    : Sinusuri ang SSL/TLS certificate validity at HTTP structure para" && \
echo "                  matukoy kung ang link ay kahina-hinala o ligtas." && \
echo "" && \
echo -e "  \e[1;32m2. A1Z26 Cipher Decoder (a1z26)\e[0m" && \
echo "     Usage      : a1z26 \"NUMBERS\"" && \
echo "     Example    : a1z26 \"11-1-12-9\" o a1z26 \"11 1 12 9\"" && \
echo "     Purpose    : Isinasalin ang mga numero (1-26) pabalik sa katumbas nitong mga" && \
echo "                  letra (A-Z) gamit ang inline Python script." && \
echo "" && \
echo -e "  \e[1;32m3. Smart Hex XOR Decrypter (hexdec)\e[0m" && \
echo "     Usage      : hexdec <hex_string> <input_key>" && \
echo "     Example    : hexdec \"4d545e52\" 61" && \
echo "     Purpose    : Awtomatikong nagko-convert ng hex string pabalik sa raw data habang" && \
echo "                  dine-decrypt ito gamit ang XOR operations (may auto-modulo 256)." && \
echo "" && \
echo -e "  \e[1;32m4. Caesar Cipher Brute-Forcer (caesar)\e[0m" && \
echo "     Usage      : caesar \"TEXT\"" && \
echo "     Example    : caesar \"wpjvJAM{jhlzhy_k3jy9wa3k_890k2379}\"" && \
echo "     Purpose    : Awtomatikong sinusubukan ang lahat ng 26 posibleng shift ng Caesar" && \
echo "                  cipher (kasama na ang ROT13, dahil shift 13 lang naman ito) at" && \
echo "                  ipinapakita ang bawat resulta para mapili mo agad ang readable output." && \
echo "" && \
echo -e "  \e[1;32m5. CTF String Identifier (ctfid)\e[0m" && \
echo "     Usage      : ctfid \"STRING\"" && \
echo "     Example    : ctfid \"5f4dcc3b5aa765d61d8327deb882cf99\"" && \
echo "     Purpose    : Sinusuri ang isang string at nagmumungkahi kung ano itong posibleng" && \
echo "                  format (MD5/SHA hash, Base64, Hex, Binary, JWT, A1Z26, o cipher text)" && \
echo "                  kasama ang ready-to-use na command para subukan agad." && \
echo "     Note       : Iba ito sa /usr/bin/identify (ImageMagick), kaya ibang pangalan" && \
echo "                  ang ginamit para walang command clash." && \
echo "--------------------------------------------------------------------------------"'


alias win='exit'
alias clexit='exit'

# STEGANOGRAPHY SUB-MENU (shelp)
alias shelp='echo -e "\n\e[1;34m[🖼️] STEGANOGRAPHY COMMAND LIST & CHEATSHEET\e[0m" && \
echo "DESCRIPTION: Use this when you suspect data is hidden inside images or audio files." && \
echo "WHEN TO USE: During CTFs or Forensics cases where files contain invisible embedded secrets." && \
echo "--------------------------------------------------------------------------------" && \
echo "  Steghide Extract : steghide extract -sf <file.jpg/wav>" && \
echo "                     [USE WHEN: May alam kang passphrase/password para makuha ang nakatagong file.]" && \
echo "  Steghide Info    : steghide info <file.jpg>" && \
echo "                     [USE WHEN: Gusto mo lang malaman kung may nakatago bang file bago mo i-extract.]" && \
echo "  Stegseek (Crack) : stegseek <file.jpg> \$ROCKYOU" && \
echo "                     [USE WHEN: Hindi mo alam ang password ng steghide at gusto mo itong i-brute force gamit ang RockYou wordlist. (Napakabilis nito!)]" && \
echo "  Zsteg (PNG/BMP)  : zsteg -a <file.png>" && \
echo "                     [USE WHEN: LSB (Least Significant Bit) steganography sa PNG files para makita ang nakatagong text/flags.]" && \
echo "  Strings Scan     : strings <file.jpg> | tail -n 20" && \
echo "                     [USE WHEN: Basic check kung may biglang text na idinugtong lang sa pinaka-dulo ng file.]" && \
echo "--------------------------------------------------------------------------------" && \
echo -e "\e[1;33m[🌐] RECOMMENDED ONLINE STEGO WEBSITES:\e[0m" && \
echo "  AperiSolve        : https://www.aperisolve.com/ (Zsteg, Steghide, at Outguess scan sa isang click)" && \
echo "  Steganography On : https://steganography.online/ (Madaling visual decoder para sa web)" && \
echo "--------------------------------------------------------------------------------"'

alias cchelp='echo -e "\n\e[1;35m[✦] CRYPTOGRAPHY & FORENSICS CHEATSHEET\e[0m" && \
echo "DESCRIPTION: Use this when dealing with encoded strings, hashes, text ciphers, or broken files." && \
echo "WHEN TO USE: When you find suspicious strings, hashes, or files that refuse to open after decoding." && \
echo "--------------------------------------------------------------------------------" && \
echo "  Base64 Decode : echo -n '\''string'\'' | base64 -d" && \
echo "                  [USE WHEN: Nakakita ng maikling text na may letters, numbers, at nagtatapos sa '='.]" && \
echo "  Base64 File   : base64 -d suspicious.log > recovered_image.png" && \
echo "                  [USE WHEN: Ang BUONG log file o payload ay naglalaman ng dambuhalang block ng Base64" && \
echo "                  at gusto mong i-convert ito pabalik sa orihinal na anyo (gaya ng nakatagong larawan o file).]" && \
echo "  Hex to ASCII  : echo '\''hex_string'\'' | xxd -r -p" && \
echo "                  [USE WHEN: Ang log o payload ay puro numbers at letters A-F lang (e.g., 414243 = ABC).]" && \
echo "  Caesar (All)  : caesar \"text\"" && \
echo "                  [USE WHEN: Obvious na text pero mukhang pinagbabaligtad o scrambled ang letters. Awtomatikong ipapakita ang LAHAT ng 26 possible shifts (kasama na ang ROT13) para makita agad kung alin ang readable.]" && \
echo "  A1Z26 Decode  : a1z26 \"11-1-12-9\" o a1z26 \"11 1 12 9\"" && \
echo "                  [USE WHEN: Ang cipher ay binubuo ng mga numero mula 1 hanggang 26 na may space o hyphen.]" && \
echo "  ASCII Repeat  : python3 -c '\''print(\"char\" * count)'\''" && \
echo "                  [USE WHEN: Gumagawa ng payload para sa Buffer Overflow attacks kung saan kailangan mo ng paulit-ulit na letra (e.g., 1000 'A's).]" && \
echo "  RSA Decrypt   : openssl pkeyutl -decrypt -inkey PRIVATE_KEY -in ENCRYPTED_FILE -out OUTPUT_FILE" && \
echo "                  [USE WHEN: May nakuha kang hinarang na traffic o file na encrypted ng Asymmetric Cryptography at hawak mo ang Private Key.]" && \
echo "  Identify String: ctfid \"string\"" && \
echo "                  [USE WHEN: Hindi mo alam kung anong encoding/hash ang hawak mo. Awtomatikong susuriin at magmumungkahi ng posibleng format.]" && \
echo "--------------------------------------------------------------------------------" && \
echo -e "\e[1;32m[🔢] UNIVERSAL BINARY CONVERSION TOOLS (BASE-2):\e[0m" && \
echo "                  [USE WHEN: Nakakuha ng file na puro 0 at 1 lang ang laman at kailangang i-convert.]" && \
echo "  Binary to File: cat file.bin | tr -d '\''[:space:]'\'' | perl -lpe '\''\$_=pack\"B*\",\$_'\'' > output_file" && \
echo "                  (BEST PRACTICE: Nililinis muna ang lahat ng spaces/newlines bago i-pack ng Perl" && \
echo "                  pabalik sa orihinal nitong anyo gaya ng JPG, PNG, o TXT.)" && \
echo "  Raw Perl Only : perl -lpe '\''\$_=pack\"B*\",\$_'\''" && \
echo "                  (Gagamitin lang kung SIGURADONG magkakadikit na at walang space ang mga binary string.)" && \
echo "--------------------------------------------------------------------------------" && \
echo -e "\e[1;36m[🔎] BROKEN FILE IDENTIFICATION & CORRUPT MAGIC BYTES REPAIR:\e[0m" && \
echo "                  [USE WHEN: Ayaw bumukas ng na-extract o na-decode na file (e.g., Corrupted Image error).]" && \
echo "  Check File ID : file <filename>" && \
echo "                  (Sinusuri ang totoong file type base sa loob nito, hindi sa .extension lang.)" && \
echo "  Inspect Header: xxd <filename> | head -n 1" && \
echo "                  (Tinitingnan ang unang linya ng hex para sa Magic Bytes gaya ng JFIF o PNG.)" && \
echo "  1. Export Hex : xxd file > dump.txt" && \
echo "                  (Ginagawang readable text file ang hex bytes ng isang file para madaing ma-edit.)" && \
echo "  2. Edit Header: nano dump.txt" && \
echo "                  (Buksan ang text file at manu-manong palitan ang nakitang sirang bytes sa unahan.)" && \
echo "  3. Revert/Fix : xxd -r dump.txt > fixed_file.jpg" && \
echo "                  (Ibe-braid o ibabalik ang binagong text dump pabalik sa isang gumaganang binary/larawan.)" && \
echo "                  * Common Magic Bytes Reference:" && \
echo "                    - JPEG/JPG : ffd8 ffe0 (May '\''Simple JFIF'\'' sa kanang bahagi ng xxd)" && \
echo "                    - PNG      : 8950 4e47 (May '\''.PNG'\'' sa kanang bahagi ng xxd)" && \
echo "                    - PDF      : 2550 4446 (May '\''%PDF'\'' sa kanang bahagi ng xxd)" && \
echo "                    - ZIP      : 504b 0304 (May '\''PK'\'' sa kanang bahagi ng xxd)" && \
echo "--------------------------------------------------------------------------------" && \
echo -e "\e[1;33m[!] FOR ADVANCED XOR & DIFFIE-HELLMAN DECRYPTION:\e[0m" && \
echo -e "  Type \e[1;32mxhelp\e[0m to view usage for custom functions (dhxor & hexdec)." && \
echo "--------------------------------------------------------------------------------" && \
echo -e "\e[1;32m  [KALI BUILT-IN] HASH CRACKING WITH \$ROCKYOU:\e[0m" && \
echo "                  [USE WHEN: May nakuha kang user database o password hash sa system at gusto mong malaman ang totoong password.]" && \
echo "    1. Save hash to temporary file : echo '\''<hash_here>'\'' > /tmp/target.txt" && \
echo "    2. Crack MD5 with John       : john --format=Raw-MD5 --wordlist=\$ROCKYOU /tmp/target.txt" && \
echo "                                     (Length: 32 chars | e.g., 098f6bcd4621d373cade4e832627b4f6)" && \
echo "    3. Crack SHA-1 with John     : john --format=Raw-SHA1 --wordlist=\$ROCKYOU /tmp/target.txt" && \
echo "                                     (Length: 40 chars | e.g., a9993e364706816aba3e25717850c26c9cd0d89d)" && \
echo "    4. Crack SHA-256 with John   : john --format=Raw-SHA256 --wordlist=\$ROCKYOU /tmp/target.txt" && \
echo "                                     (Length: 64 chars | e.g., 5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8)" && \
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

# 7. OPEN SOURCE TOOL
alias thelp='echo -e "\n\e[1;32m[+] CYVERDARIAN TOOLS HELP\e[0m" && \
echo "  VirusTotal  : https://www.virustotal.com (i-search ang hash dito)" && \
echo "  CyberChef : https://gchq.github.io/CyberChef/" && \
echo "--------------------------------------------------------------------------------"'
