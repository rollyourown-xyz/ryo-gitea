# SPDX-FileCopyrightText: 2022 Wilfred Nicoll <xyzroller@rollyourown.xyz>
# SPDX-License-Identifier: GPL-3.0-or-later

services {
  name = "gitea-http"
  tags = [ "git", "webserver" ]
  port = 3000
}

services {
  name = "gitea-ssh"
  tags = [ "git", "ssh", "tcp" ]
  port = 3022
}
