# Nectar VM scripts

## Installation on Nectar VM

The following instructions have been validated with a Nectar VM configured as follows:

* Image Name: `NeCTAR Ubuntu 22.04 LTS (Jammy) amd64`
* Flavour Name: `t3.xsmall`
* Security Groups: Add `SSH, HTTP and HTTPS` security group, which supplies:

    > ALLOW IPv4 22/tcp from 0.0.0.0/0  
    > ALLOW IPv4 443/tcp from 0.0.0.0/0  
    > ALLOW IPv4 80/tcp from 0.0.0.0/0  
    > ALLOW IPv6 to ::/0  
    > ALLOW IPv4 to 0.0.0.0/0  
    > ALLOW IPv4 8080/tcp from 0.0.0.0/0  

## VM Config

In what follows, you will need the following, once the VM is instantiated:

* IP Address: available from the dashboard
* A project password to access the NeCTAR Cloud using the OpenStack API.  Obtained by navigating to `<email>->Settings->Reset Password` and creating a new password.

## Repo install

* Locally:
    * Make sure your nectar key has been enabled locally with:
    ```
    ssh-add <path/to/key>
    ```
    * Copy a valid github key to the VM with:
    ```
    scp KEYNAME* ubuntu@IP_ADDRESS:/home/ubuntu/.ssh/
    ```
* On the VM:
    * Start the ssh agent with:
    ```
    eval "$(ssh-agent)"
    ```
    * Add the key to the agent (submit password when asked):
    ```
    ssh-add .ssh/KEYNAME
    ```
    * Clone this REPO and the application REPO: 
    ```
    git clone git@github.com:gbpoole/nectar_scripts.git
    ```
    ```
    git clone git@github.com:gbpoole/REPO.git
    ```
    * [Optionally] if you will edit the code locally, you'll want to do the following:
    ```
    git config --global user.name "Your Name"
    git config --global user.email "your@email.address"
    git config --global core.editor "vi"
    ```
    and from within the REPO:
    ```
    git remote set-url origin git@github.com:gbpoole/REPO.git
    ```

## Install requirements

* [Optionally] Install Docker with (enter y-and-return when prompted): 
  ```
  sudo ~/nectar_scripts/install_Docker_on_Ubuntu.sh
  ```
* Install Python with (enter y-and-return when prompted):
  ```
  sudo ~/nectar_scripts/install_Python_on_Ubuntu.sh
  ```
* Create a virtual environment and activate it:
  ```
  python3 -m venv venv
  . venv/bin/activate
  ```
* Install Poetry with:
  ```
  ~/nectar_scripts/install_Poetry.sh
  ```
  and then add it to your path:
  ```
  export PATH="/home/ubuntu/.local/bin:$PATH"
  ```
* Install the OpenStack client:
  ```
  ~/nectar_scripts/install_OpenStack_client.sh
  ```
* Install certbot (enter y-and-return when prompted):
  ```
  sudo ~/nectar_scripts/install_certbot_on_Ubuntu.sh
  ```
* Install Nginx (enter y-and-return when prompted):
  ```
  sudo ~/nectar_scripts/install_Nginx_on_Ubuntu.sh
  ```

## Set-up DNS name

1. Install `Open Stack CLI` client:
	* Obtain Open Stack rc file from the dashboard: by clicking (in the top bar) on `<email>->OpenStack RC File`
	* scp rc file to the VM:
        ```
        scp <rc-file-name.sh> ubuntu@IP_ADDRESS:/home/ubuntu/
        ```
	* source the file on the VM (enter project password when asked):
        ```
        . <rc-file-name.sh>
        ```
2. Execute the following with the client:
	* check that your project has the default zone as follows: 
        ```
        openstack zone list
        ```
    * add a DNS record for your instance to the zone as follows:
        ```
        openstack recordset create <project>.cloud.edu.au. <instance name> --type A --record <instance IP addr>
        ```

> [!NOTE]
> If a "Duplicate Record Set" error is thrown, then you need to delete the old one first:
> ```  
> openstack recordset delete <project>.cloud.edu.au.  <instance name>.<project>.cloud.edu.au.
> ```
> then, retry the openstack recordset create command above.

## Set-up Nginx

* Verify that Nginx registered itself as a service with ufw when it installed:
    ```
    sudo ufw app list
    ```
	* You should see something like:

        > Available applications:  
        >   Nginx Full  
        >   Nginx HTTP  
        >   Nginx HTTPS  
        >   OpenSSH  

* Verify that Nginx was started at the install:
    ```
    systemctl status nginx
    ```
	* You should see something like:

        > ● nginx.service - A high performance web server and a reverse proxy server  
        >      Loaded: loaded (/lib/systemd/system/nginx.service; enabled; vendor preset: enabled)  
        >      Active: active (running) since Wed 2022-08-03 04:35:19 UTC; 3min 17s ago  
        >        Docs: man:nginx(8)  
        >     Process: 44621 ExecStartPre=/usr/sbin/nginx -t -q -g daemon on; master_process on; (code=exited, status=0/SUCCESS)  
        >     Process: 44631 ExecStart=/usr/sbin/nginx -g daemon on; master_process on; (code=exited, status=0/SUCCESS)  
        >    Main PID: 44632 (nginx)  
        >       Tasks: 2 (limit: 1144)  
        >      Memory: 5.1M  
        >      CGroup: /system.slice/nginx.service  
        >              ├─44632 nginx: master process /usr/sbin/nginx -g daemon on; master_process on;  
        >              └─44633 nginx: worker process  
        >  
        > Aug 03 04:35:19 <dns-name> systemd[1]: Starting A high performance web server and a reverse proxy server...  
        > Aug 03 04:35:19 <dns-name> systemd[1]: Started A high performance web server and a reverse proxy server.  

* Copy Nginx config files into place:
    ```
    sudo cp ~/nectar_scripts/nginx.config /etc/nginx/sites-available/<dns-name>
    ```
* Make a link to this file:
    ```
    sudo ln -s /etc/nginx/sites-available/<dns-name> /etc/nginx/sites-enabled/
    ```
* remove the default site (note, a copy will remain at rm /etc/nginx/sites-available/default if you need it):
    ```
    sudo rm /etc/nginx/sites-enabled/default
    ```
* Restart Nginx:
    ```
    sudo systemctl restart nginx.service
    ```

## Set-up a "Let's Encrypt" Certificate

* Certbot only works with Python 3.5 to 3.8, so watch-out for the install of Python 3.10 above!
* The following commands, for switching python3 versions might be handy:
    ```
    sudo update-alternatives --set python3 /usr/bin/python3.10
    ```
    ```
    sudo update-alternatives --set python3 /usr/bin/python3.8
    ```

* Create a new venv and run certbot from there:
    ```
    python3 -m venv myenv
    ```
    ```
    . ~/nectar_scripts/myenv/bin/activate
    ```
    ```
    pip3 install certbot certbot-nginx
    ```
    ```
    sudo myenv/bin/certbot --nginx -d <dns-name>.adacs-gpoole.cloud.edu.au
    ```

* For a 1-time renewal:
    ```
    sudo certbot renew
    ```

## Auto-renewal of SSL

* Edit the following 2 files (`sudo vi`):

    1. `/etc/systemd/system/certbot.service`

        ```
        [Unit]
        Description=Let's Encrypt renewal

        [Service]
        Type=oneshot
        ExecStart=/usr/bin/certbot renew --quiet --agree-tos
        ExecStartPost=/bin/systemctl reload apache2.service
        ```

    2. `/etc/systemd/system/certbot.timer`

        ```
        [Unit]
        Description=Twice daily renewal of Let's Encrypt's certificates

        [Timer]
        OnCalendar=0/12:00:00
        RandomizedDelaySec=1h
        Persistent=true

        [Install]
        WantedBy=timers.target
        ```

* Enable and start `certbot.timer`:
    ```
    systemctl enable --now certbot.timer
    ```

* Check the status of the timer
    ```
    sudo systemctl status certbot.timer
    ```

## Run an app

* Install Poetry.  Add to path:
    ```
    export PATH="/home/ubuntu/.local/bin:$PATH"
    ```
* Create a venv (if not done already):
    ```
    ~/nectar_scripts/scripts/create_venv.sh
    ```
* Source venv:
    ```
    source venv/bin/activate
    ```
* Install the app with:
    ```
    poetry install
    ```
* To use docker-compose to start the app (from the repo directory):
    ```
    sudo docker-compose up -d
    ```
* Otherwise:
    ```
    gunicorn app.main:app -c gunicorn.nectar.conf.py
    ```
