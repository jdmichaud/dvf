FROM ubuntu:latest

RUN apt-get update && apt-get -y install cron curl git gzip
RUN curl -sOL https://downloads.sourceforge.net/project/videlibri/Xidel/Xidel%200.9.8/xidel_0.9.8-1_amd64.deb
RUN dpkg -i xidel_0.9.8-1_amd64.deb

COPY . /root/dvf
RUN cp /root/dvf/dvf-update-cron /etc/cron.d/dvf-update-cron

# Give execution rights on the cron job 
RUN chmod 0644 /etc/cron.d/dvf-update-cron 
 
# Apply cron job 
RUN crontab /etc/cron.d/dvf-update-cron
 
# Create the log file to be able to run tail
RUN touch /var/log/cron.log
 
# Initially the repo will not be configured with a token.
CMD cd /root/dvf/ && \
  git remote remove origin && \
  git remote add origin https://$gh_token@github.com/jdmichaud/dvf.git && \
  cron && tail -f /var/log/cron.log

