Base image for web-based PHP projects

# List of main packages:
- Nginx 1.10.x
- Node.js 7.x (+ gulp 3.9.x)
- PHP 7.0.x

# Init system
For handling multiple-services init, [s6-init](https://github.com/just-containers/s6-overlay) init system is used here.

- If you want some script to be run automatically at container start-up:
Add it as `99-<name>` to the `/etc/cont-init.d` directory in your image.
You should use `#!/usr/bin/with-contenv bash` header shebang if you need an access
to container variables in that script.
