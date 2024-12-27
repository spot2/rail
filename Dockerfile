FROM debian
ARG NGROK_TOKEN
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt update && apt upgrade -y && apt install -y \
    ssh wget unzip vim curl python3

# Install latest ngrok
RUN wget -q https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz -O /ngrok-v3-stable-linux-amd64.tgz \
    && cd / && tar -xvzf ngrok-v3-stable-linux-amd64.tgz \
    && chmod +x ngrok

# Configure SSH and ngrok
RUN mkdir /run/sshd \
    && echo "/ngrok tcp 22 --authtoken=${NGROK_TOKEN} &" >>/openssh.sh \
    && echo "sleep 5" >> /openssh.sh \
    && echo "curl -s http://localhost:4040/api/tunnels | python3 -c \"import sys, json; data = sys.stdin.read(); tunnels = json.loads(data).get('tunnels', []); print(f'ssh info:\\n ssh root@{tunnels[0][\\\"public_url\\\"][6:].replace(\\\":\\\", \\\" -p \\\" )}\\nROOT Password:craxid') if tunnels else print('Error: Ngrok tidak memberikan URL.')\"" >> /openssh.sh \
    && echo '/usr/sbin/sshd -D' >> /openssh.sh \
    && echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config \
    && echo root:craxid | chpasswd \
    && chmod 755 /openssh.sh

# Expose ports
EXPOSE 80 443 3306 4040 5432 5700 5701 5010 6800 6900 8080 8888 9000

# Set entrypoint
CMD /openssh.sh
