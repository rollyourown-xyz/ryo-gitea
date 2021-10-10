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
