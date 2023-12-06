from scapy.all import IP, DNS, sniff
import sys

# logging
INFO = "{*}"
#//ERR = "{-}"
#//OK = "{+}"
IMP = "{!}" 
#//SIMP = "{!!}" # will we ever use this?????

def printsay(status=INFO, say=any):
    print(f'{status} {say}')

def querysniff(pkt):
    if pkt.haslayer(IP):
        ip_src = pkt[IP].src
        ip_dst = pkt[IP].dst
        if pkt.haslayer(DNS):
            dns_layer = pkt.getlayer(DNS)
            qname = dns_layer.qd.qname.decode('utf-8')  # Decode the DNS query name
            print(f'{str(ip_src)} -> {str(ip_dst)} : ({qname})')

try:
    interface = input(f"{INFO} Enter interface: ")
except KeyboardInterrupt:
    printsay(IMP, "User requested shutdown")
    printsay(say="Exiting...")
    sys.exit(1)

sniff(iface=interface,filter="port 53",prn=querysniff,store=0)
printsay(INFO, "Shutting Down...")