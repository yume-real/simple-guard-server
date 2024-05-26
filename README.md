# Simple Guard Server

Simple Guard Server is a security script designed to monitor SSH connections to a VPS and send notifications to a Discord channel when a new connection is established. The script also restricts SSH access during specific hours.

## Features

- **Discord Notifications**: Sends a message to a specified Discord channel when a new SSH connection is made.
- **IP Logging**: Logs the IP address of the user and the VPS.
- **Time-based SSH Access**: Automatically restricts SSH access during non-working hours (00:00 - 08:00 according to the Europe/Moscow time zone).

## Installation Guide

### Prerequisites

1. **VPS**: You need a VPS with SSH access.
2. **Discord Webhook**: Create a webhook in your Discord server and note the URL.
3. **Role ID**: Note the role ID of the role you want to mention.

### Getting Started

1. **Clone the Repository**

   ```bash
   git clone https://github.com/yume-real/simple-guard-server/
   cd Simple-Guard-Server
   ```

2. **Configure the Script**

   Edit the script `simple-guard-server.sh` and replace `YOUR_WEBHOOK_URL` and `YOUR_ROLE_ID` with your actual Discord webhook URL and role ID:

   ```bash
   discord_webhook_url="YOUR_WEBHOOK_URL"
   role_id="YOUR_ROLE_ID"
   ```

3. **Ensure Required Tools are Installed**

   Make sure `ufw`, `jq`, and `curl` are installed:

   ```bash
   sudo apt-get update
   sudo apt-get install ufw jq curl
   ```

4. **Set Script Permissions**

   Grant execution permissions to the script:

   ```bash
   chmod +x simple-guard-server.sh
   ```

5. **Run the Script**

   Execute the script to start monitoring SSH connections:

   ```bash
   ./simple-guard-server.sh
   ```

### Running as a Service (Optional)

To run the script as a service and ensure it starts on boot, you can create a systemd service unit:

1. **Create Service Unit File**

   ```bash
   sudo nano /etc/systemd/system/simple-guard-server.service
   ```

2. **Add the Following Content**

   ```ini
   [Unit]
   Description=Simple Guard Server

   [Service]
   ExecStart=/path/to/your/simple-guard-server.sh
   Restart=always
   User=root

   [Install]
   WantedBy=multi-user.target
   ```

   Make sure to replace `/path/to/your/simple-guard-server.sh` with the actual path to your script.

3. **Enable and Start the Service**

   ```bash
   sudo systemctl daemon-reload
   sudo systemctl enable simple-guard-server
   sudo systemctl start simple-guard-server
   ```

4. **Check Service Status**

   Verify that the service is running with:

   ```bash
   sudo systemctl status simple-guard-server
   ```

## Usage

The script continuously monitors SSH connections. When a new connection is detected, it sends a message to the specified Discord channel with the connection details, including the time, username, user's IP address, and the VPS IP address. The script also adjusts SSH access permissions according to the specified time rules.

## Contributing

Feel free to submit issues or pull requests to enhance the functionality or fix bugs.

## License

MIT License

Enjoy secure and monitored SSH access with Simple Guard Server!
