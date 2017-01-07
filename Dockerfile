FROM oberthur/docker-ubuntu:16.04

ENV TERM=xterm-256color

RUN apt-get -q update >/dev/null \
  && apt-get install -y openssh-server \
  && mkdir /var/run/sshd \

  # Auto-create user's homedir
  && echo "\n# Auto-create user's homedir" >> /etc/pam.d/common-account \
  && echo "session    required   pam_mkhomedir.so skel=/etc/skel/ umask=${HOMEDIR_UMASK:-0077}" >> /etc/pam.d/common-account \
  # SSH keys from file auth script
  && echo "AuthorizedKeysCommand /auth-script.sh" >> /etc/ssh/sshd_config \
  && echo "AuthorizedKeysCommandUser nobody" >> /etc/ssh/sshd_config \

  # Cleanup
  && apt-get clean autoclean \
  && apt-get autoremove --yes \
  && rm -rf /var/lib/{apt,dpkg,cache,log}/ 

COPY auth-script.sh /auth-script.sh
COPY start_ssh_server.sh /usr/bin/start_ssh_server.sh

#RUN chmod 755 /auth-script.sh && chown root.root /auth-script.sh

ENTRYPOINT ["/usr/bin/start_ssh_server.sh"]