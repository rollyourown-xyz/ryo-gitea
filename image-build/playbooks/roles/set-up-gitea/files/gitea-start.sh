#!/bin/sh
# SPDX-FileCopyrightText: 2022 Wilfred Nicoll <xyzroller@rollyourown.xyz>
# SPDX-License-Identifier: GPL-3.0-or-later


# If the file "BOOTSRTAPPED" is not already present then run bootstrapping tasks
if [ ! -f "/etc/gitea/BOOTSTRAPPED" ]; then

  # Create sub-directories for gitea files (ownership gitea:gitea)
  mkdir /var/lib/gitea/custom
  chown gitea:gitea /var/lib/gitea/custom
  mkdir /var/lib/gitea/custom/templates
  chown gitea:gitea /var/lib/gitea/custom/templates
  mkdir /var/lib/gitea/custom/templates/custom
  chown gitea:gitea /var/lib/gitea/custom/templates/custom
  mkdir /var/lib/gitea/data
  chown gitea:gitea /var/lib/gitea/data
  mkdir /var/lib/gitea/log
  chown gitea:gitea /var/lib/gitea/log
  mkdir /var/lib/gitea/.ssh
  chown gitea:gitea /var/lib/gitea/.ssh
  
  # Copy gitea config file
  cp -p /usr/local/bootstrap/app.ini /etc/gitea/app.ini
  
  # Run gitea migrate
  sudo -u gitea /usr/local/bin/gitea -w /var/lib/gitea/ -c /etc/gitea/app.ini migrate
  
  # Wait 10 seconds
  sleep 10
  
  # Add admin user
  /usr/local/bootstrap/gitea-admin.sh
  
  # Add file BOOTSTRAPPED to indicate no further bootstrapping needed
  touch  /etc/gitea/BOOTSTRAPPED

fi

# Copy gitea config file
cp -p /usr/local/bootstrap/app.ini /etc/gitea/app.ini

# Copy gitea footer extra links file
cp -p /usr/local/bootstrap/extra_links_footer.tmpl /var/lib/gitea/custom/templates/custom/extra_links_footer.tmpl

# Change to /etc/gitea diretory, generate new SSL certificates and make readable to gitea user 
cd /etc/gitea
/usr/local/bin/gitea cert --host * --duration 87600h0m0s
chown gitea:gitea /etc/gitea/cert.pem
chown gitea:gitea /etc/gitea/key.pem

# Enable and start gitea
systemctl enable gitea.service
systemctl start gitea.service
