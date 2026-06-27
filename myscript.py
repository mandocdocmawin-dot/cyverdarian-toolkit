import socket
import sys
import threading

# Listahan para itabi ang lahat ng aktibong koneksyon ng mga client
mga_koneksyon = []

def hawakan_ang_client(conn, addr):
    print(f"\n[+] Bagong Client na nakakonekta: {addr}")
    while True:
        try:
            # Mag-abang ng mensahe mula sa partikular na client na ito
            data = conn.recv(1024).decode('utf-8')
            if not data or data.strip().lower() == 'exit':
                print(f"\n[-] Umalis na ang Client: {addr}")
                break
            
            print(f"\n[{addr[0]}:{addr[1]}]: {data.strip()}")
            
            # (Optional) I-broadcast o ipasa ang mensahe sa lahat ng iba pang client
            ipasa_sa_lahat(f"[{addr[1]}]: {data.strip()}", conn)
            
        except ConnectionResetError:
            break

    # Kapag nadisconnect ang client, alisin sa listahan
    if conn in mga_koneksyon:
        mga_koneksyon.remove(conn)
    conn.close()

def ipasa_sa_lahat(mensahe, sender_conn):
    # Ipinapadala ang mensahe sa lahat ng naka-connect maliban sa nagpadala
    for client in mga_koneksyon:
        if client != sender_conn:
            try:
                client.sendall(mensahe.encode('utf-8'))
            except:
                client.close()
                if client in mga_koneksyon:
                    mga_koneksyon.remove(client)

def simulan_ang_server(port=4444):
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server.bind(('0.0.0.0', port))
    
    # Lakihan ang listen capacity (halimbawa, hanggang 5 clients sabay-sabay)
    server.listen(5)
    print(f"[+] Server ay bukas sa port {port}. Nag-aabang ng maraming koneksyon...")
    
    while True:
        try:
            conn, addr = server.accept()
            mga_koneksyon.append(conn)
            
            # Gumawa ng bagong thread para sa client na ito para hindi ma-block ang main loop
            thread = threading.Thread(target=hawakan_ang_client, args=(conn, addr))
            thread.daemon = True # Kusang magsasara kapag pinatay ang server
            thread.start()
            
        except KeyboardInterrupt:
            print("\n[-] Sinasara na ang Server.")
            break
            
    server.close()

def simulan_ang_client(ip, port=4444):
    client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    try:
        print(f"[...] Kumokonekta sa {ip}:{port}...")
        client.connect((ip, port))
        print("[+] Nakakonekta! Mag-type ng mensahe (o 'exit' para umalis).")
        
        # Thread para sa pag-tanggap ng mga mensahe mula sa server/ibang client habang nagtytype ka
        def tanggapin_mensahe():
            while True:
                try:
                    data = client.recv(1024).decode('utf-8')
                    if not data:
                        print("\n[-] Naputol ang koneksyon sa Server.")
                        break
                    print(f"\n{data}")
                except:
                    break

        r_thread = threading.Thread(target=tanggapin_mensahe)
        r_thread.daemon = True
        r_thread.start()

        # Pangunahing loop para sa pagpapadala ng iyong sariling chat
        while True:
            mensahe = input()
            if mensahe.strip().lower() == 'exit':
                client.sendall(b'exit')
                break
            if mensahe.strip():
                client.sendall(mensahe.encode('utf-8'))
                
    except ConnectionRefusedError:
        print("[-] Error: Hindi makakonekta sa Server.")
    finally:
        client.close()

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Paggamit:")
        print("  Server: python3 myscript.py --server")
        print("  Client: python3 myscript.py --client [IP]")
        sys.exit(1)
        
    mode = sys.argv[1]
    if mode == "--server":
        simulan_ang_server()
    elif mode == "--client":
        if len(sys.argv) < 3:
            print("[-] Ilagay ang IP ng Server.")
            sys.exit(1)
        simulan_ang_client(sys.argv[2])
