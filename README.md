# Simple Mesh Watchdog (smwd)

This is simple ash script for usage in OpenWRT, that sets all mesh parameters and removes phantom nodes if they appear.

## How to install


### 1. Copy three files to your router:
- bin/smwd.sh => /usr/local/smwd.sh
- config/smwd => /etc/config/smwd
- init.d/smwd => /etc/init.d/smwd



### 2. Make necessary files executable:
- chmod +x /usr/local/smwd.sh
- chmod +x /etc/init.d/smwd



### 3. Start smwd service:
- In terminal: /etc/init.d/smwd start
- In LuCI: System -> Startup -> smwd -> Start



### 4. Enable and tweak smwd service:
- Edit /etc/config/smwd to edit mesh_param. There is no need to do anything after editing mesh_params. You are going to see logs about changed mesh_params
- Enable service (/etc/init.d/smwd enable // LuCI -> Startup -> smwd -> Enable). This is going to start smwd on startup.
