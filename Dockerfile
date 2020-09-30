FROM phusion/baseimage:master
MAINTAINER lovebootcaptain

# Set correct environment variables
ENV HOME /root
ENV DEBIAN_FRONTEND noninteractive
ENV LC_ALL C.UTF-8
ENV LANG de_DE.UTF-8
ENV LANGUAGE de_DE.UTF-8

# Use baseimage-docker's init system
CMD ["/sbin/my_init"]

# Configure user nobody to match unRAID's settings
RUN \
 usermod -u 99 nobody && \
 usermod -g 100 nobody && \
 usermod -d /home nobody && \
 chown -R nobody:users /home

# Disable SSH
RUN rm -rf /etc/service/sshd /etc/my_init.d/00_regen_ssh_host_keys.sh

RUN apt-get update
RUN apt-get -y install apt-transport-https ca-certificates
RUN apt-get -y install wget nano bash-completion expect
RUN apt-get -y upgrade

# newer pycharm version won't build localy without the -q arg on wget :(
RUN	wget -qO - https://repo.jotta.us/public.gpg | apt-key add - && \
	echo "deb https://repo.jotta.us/debian debian main" | tee /etc/apt/sources.list.d/jotta-cli.list

RUN	apt-get update
RUN	apt-get -y install jotta-cli
RUN apt-get clean

# add code completion in interactive mode for bash and jotta-cli
RUN echo "if [ -f /etc/bash_completion ] && ! shopt -oq posix; then\n. /etc/bash_completion\nfi\n. <(jotta-cli completion)" >> /root/.bashrc

# copy in files
ADD /jottad/ /usr/local/jottad

# add execute permission
RUN chmod +x /usr/local/jottad/* /etc/init.d/jottad

# your backup mount
VOLUME /sync

# for persitance of login token, userconfig, etc
VOLUME /var/lib/jottad

# setup container and start service
ENTRYPOINT ["/usr/local/jottad/entrypoint.sh"]
