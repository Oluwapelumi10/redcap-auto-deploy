# 🚀 REDCap Automated Deployment using Terraform & Ansible on AWS

This is a hands-on DevOps lab project where I automated the deployment of a REDCap server infrastructure using **Terraform** and **Ansible** on **AWS EC2 instances**. The goal was to replicate a real-world setup used in NHS environments, enabling modular and repeatable infrastructure builds with full automation.

* ✅ Fully automated from provisioning to REDCap configuration.
* ✅ Based on real infrastructure used in research and clinical environments.
* ✅ Built for learning and showcasing DevOps automation


## 📌 Purpose of the Project

This project simulates the full automation of REDCap server deployment using Terraform and Ansible. The goal is to demonstrate how to:

- Provision infrastructure in AWS using Terraform
- Automate the installation and configuration of REDCap, MariaDB, Apache, PHP, CRON, and Postfix
- Follow best practices for idempotent and secure server setups
- Structure DevOps projects for clarity, reusability, and scalability

Although this is a simulation (not using the official REDCap licensed files), the steps strictly follow the same procedure that would be used in a real-world production deployment — including configuration structure, automation flow, and system behavior.


---

## ⚙️ Tools & Technologies Used

| Tool              | Purpose                                             |
| ----------------- | --------------------------------------------------- |
| Terraform         | Provision EC2, VPC, subnets, and security groups    |
| Ansible           | Configure software on EC2 (Apache, MariaDB, REDCap) |
| AWS EC2 (Ubuntu)  | Host REDCap app and database                        |
| Apache Web Server | Serve the REDCap frontend                           |
| MariaDB           | REDCap database backend                             |
| SSH               | Remote login and secure configuration               |
| Git & GitHub      | Version control and documentation                   |
| Postfix + CRON    | Email simulation and task automation                |

---

## 🌍 Architecture Diagram

Terraform provisions a VPC, public/private subnets, and 3 EC2 instances:

* **Ansible Controller** (Public Subnet)
* **Web Server** (Public Subnet)
* **Database Server** (Private Subnet)

Traffic is allowed via:

* HTTP/HTTPS (80/443) to Web Server
* SSH (22) for remote access
* SQL (3306) from Web to DB server


<img width="1278" height="641" alt="Archi Diagram" src="https://github.com/user-attachments/assets/54b88ecf-2d63-4307-b65a-107b0f060931" />


---

## 📁 Project Folder Structure

```
redcap-Auto-Deploy/
│
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── output.tf
│   ├── terraform.tfstate
│
├── redcap-ansible/
│   ├── inventory.ini
│   ├── site.yml
│   └── roles/
│       ├── web/
│       │   ├── tasks/main.yml
│       │   └── templates/
│       │       ├── 000-default.conf.j2
│       │       ├── database.php.j2
│       │       ├── check_db.php.j2
│       │       └── cron.sh.j2
│       └── database/
│           └── tasks/main.yml
│
├── redcap-build/
│   └── redcap10.0.26.zip
│   └── redcap/ (unzipped dummy frontend)
│
├── README.md ✅

```



## 🚀 Deployment Phase

This section explains how the REDCap infrastructure was deployed and configured using **Terraform** and **Ansible** on **AWS EC2 instances**.

✅ Provisioned a secure custom VPC with 3 EC2 instances  
✅ SSH access from local machine to Ansible controller  
✅ Ansible playbook configured Apache, MariaDB, PHP, and REDCap  
✅ All components fully automated no manual setup  
✅ Designed to simulate real-world clinical research infra

### 🛠 Step 1: Deploy Infrastructure with Terraform

I navigated to the `terraform/` directory and ran the following commands:

```bash
cd terraform
terraform init        # Initialize Terraform and download AWS provider
terraform validate    # Check .tf syntax for errors
terraform plan        # Review planned changes
terraform apply       # Provision AWS infrastructure
```
<table>
  <tr>
    <td align="center">
      <img src="https://github.com/user-attachments/assets/ce63124f-4efe-4972-9b66-aaad3083ab5e" alt="Terraform Output" width="500" />
      <br><em>Terraform Output</em>
    </td>
  </tr>
</table>




### ✔️ Outcome
 This step provisions:
- Ansible Controller (Public Subnet)
- Web Server (Public Subnet)
- Database Server (Private Subnet)
- Internet Gateway
- Route Table
- Security Groups


### 🔐 Step 2: SSH into Ansible Controller

After deployment, SSH’d into the Ansible controller to start configuring the environment:

```bash
ssh -i ~/.ssh/id_rsa ubuntu@<controller_public_ip>
```
<table>
  <tr>
    <td align="center">
      <img src="https://github.com/user-attachments/assets/256d14b6-8f00-420e-8a5e-8db01d8a8e2d" width="500" />
      <br><em>Remote access into controller</em>
    </td>
  </tr>
</table>



### ⚙️ Step 3: Install Ansible on Controller

Updated the server and installed Ansible:

```bash
sudo apt update -y
sudo apt install ansible -y
ansible --version
```
| ![Ansible Install](https://github.com/user-attachments/assets/7bd9bf65-386a-4f00-8c2c-f9a7be8bd0ea) | ![Ansible Version](https://github.com/user-attachments/assets/2a1a3424-8479-4b4e-81b1-638c057519a1) |
|:--:|:--:|
| *Ansible Installed* | *Version Check* |




### 📦 Step 4: Transfer REDCap Project Files to EC2

I copied the entire `redcap-ansible/` folder (with roles, playbook, templates) to the controller via SCP:

```bash
scp -i ~/.ssh/id_rsa -r redcap-ansible ubuntu@<controller_ip>:~/
```
| ![copy-zip-to-controller.png](https://github.com/user-attachments/assets/bf2fca5c-e81a-419a-90d5-75fe5b0e177c) |
|:--:|
| *copy-zip-to-controller.png* |



### 📂 Step 5: Configure Ansible Inventory and Playbook

I defined the target hosts and grouped them inside `inventory.ini`. This allowed Ansible to target specific servers like the web and database nodes.

```ini
[web]
<web_server_private_ip>

[db]
<database_server_private_ip>
Then I created a site.yml playbook to run multiple roles in order (web, database).
```
| ![site yml](https://github.com/user-attachments/assets/c8e36ac7-1486-4b72-9b12-3886d054e13d) | ![inventory ini](https://github.com/user-attachments/assets/1f72343e-345c-41d3-90ea-d80b072e98f2) |
|:--:|:--:|
| *site.yml* | *inventory.ini* |





### 🔧 Step 6: Configure Apache with Ansible

```md
I created a role `web` with tasks to install Apache and place a custom `000-default.conf`:

- Installed Apache using `apt`
- Uploaded the Apache config using Jinja2 template
- Restarted the service
```
| ![apachehost-config](https://github.com/user-attachments/assets/09d1de97-d8f3-4be5-9b6c-000cb4da4da3) | ![default main yml](https://github.com/user-attachments/assets/9a29a26e-73f5-417e-90d9-80c5856e4a60) |
|:--:|:--:|
| *apachehost-config* | *default/main.yml* |





### 🗃️ Step 7: Install and Configure MariaDB

Using the `database` role, I automated the installation and configuration of MariaDB:

- Installed MariaDB
- Set root password and hardening
- Created `redcap` database and `redcapuser`
- Granted privileges

<table>
  <tr>
    <td align="center">
      <img src="https://github.com/user-attachments/assets/475a9bfe-0b57-4a63-b8f4-95dfd4590f28" width="400" alt="MariaDB Installed" /><br/>
      <sub>✅ MariaDB installed via APT</sub>
    </td>
    <td align="center">
      <img src="https://github.com/user-attachments/assets/dcaf1084-56f6-4fb8-aee1-d129d5fcb9a6" width="400" alt="MariaDB service running" /><br/>
      <sub>🟢 MariaDB service running</sub>
    </td>
    <td align="center">
      <img src="https://github.com/user-attachments/assets/7eac8e83-f206-4f32-8880-35080fb340b0" width="400" alt="Privileges Granted" /><br/>
      <sub>🔐 Privileges granted to <code>redcap_user</code></sub>
    </td>
  </tr>
  <tr>
    <td align="center">
      <img src="https://github.com/user-attachments/assets/e048d71a-73f2-4a19-9306-c8bc74494410" width="400" alt="Security Hardened" /><br/>
      <sub>🔒 Security hardening via <code>mysql_secure_installation</code></sub>
    </td>
    <td align="center">
      <img src="https://github.com/user-attachments/assets/7aac643f-da32-40ef-9e0b-61f2bbbf39c3" width="400" alt="Database Created" /><br/>
      <sub>📁 <code>redcap</code> database successfully created</sub>
    </td>
    <td align="center">
      <br/><br/>
      <sub> </sub>
    </td>
  </tr>
</table>




### 🌐 Step 8: Deploy REDCap App to Web Server

I copied the `redcap10.0.26.zip` build and unzipped it inside `/var/www/html/redcap`.

- Ensured directory structure was correct
- Placed `database.php.j2` to connect to DB
- Set correct permissions

<table>
  <tr>
    <td align="center">
      <img src="https://github.com/user-attachments/assets/e1d16db5-28cb-403a-9934-d7477f805aa0" width="400" alt="Redcap ZIP File" /><br/>
      <sub>📦 REDCap ZIP file in local Downloads folder</sub>
    </td>
    <td align="center">
      <img src="https://github.com/user-attachments/assets/857c3207-9e90-412e-9963-aa6caedd5ab1" width="400" alt="Upload to Web Server" /><br/>
      <sub>⬆️ Uploading ZIP file to web server via <code>scp</code></sub>
    </td>
  </tr>
  <tr>
    <td align="center">
      <img src="https://github.com/user-attachments/assets/8c30886e-20eb-417f-9f27-33a24f29fc78" width="400" alt="REDCap Homepage" /><br/>
      <sub>🌐 REDCap application showing in browser</sub>
    </td>
    <td align="center">
      <img src="https://github.com/user-attachments/assets/94711e25-681e-4999-8cbc-d5550cb8d048" width="400" alt="Database PHP Check" /><br/>
      <sub>🔧 Testing DB connection with <code>database.php</code></sub>
    </td>
  </tr>
</table>




### ✅ Step 9: Verify REDCap & Database Connectivity

I verified the success of the deployment by testing the following:

- Accessed the REDCap app via browser using the public IP of the web server
- Confirmed the frontend loaded without 404 errors
- Created and placed `check_db.php` in the web directory to confirm DB connection
- Checked logs and page response for SQL connectivity confirmation

<table> <tr> <td align="center"> <img src="https://github.com/user-attachments/assets/06dc931c-285d-4d9c-9315-c238f5982778" width="400" alt="Login Successful" /><br/> <sub>🔓 Test web login successful (Apache serving REDCap)</sub> </td> <td align="center"> <img src="https://github.com/user-attachments/assets/2c39b399-f925-4554-a971-fab50e576248" width="400" alt="check_db.php successful" /><br/> <sub>✅ <code>check_db.php</code> Deployed successfully</sub> </td> </tr> <tr> <td align="center"> <img src="https://github.com/user-attachments/assets/8a905560-b2c4-4857-aaab-eed1c58f716e" width="400" alt="check_db.php confirmed" /><br/> <sub>📋 Confirmed DB connection with table listing</sub> </td> <td align="center"> <img src="https://github.com/user-attachments/assets/66e0859c-5b71-44d1-a090-ca3281d6a9ff" width="400" alt="index.php" /><br/> <sub>🏠 REDCap homepage (<code>index.php</code>) successfully loaded</sub> </td> </tr> </table>




### 🕒 Step 10: Set Up Cron Job + Simulate Email with Postfix

To test REDCap's background task automation and email functionality, I:

- Created a dummy cron job file (`cron.sh`) using Ansible
- Installed Postfix and configured it for local mail delivery
- Verified the script ran successfully from CRON
- Simulated email delivery from the cron task

<table> <tr> <td align="center"> <img src="https://github.com/user-attachments/assets/85449bf9-884d-426f-96b7-d29e8e5465bd" width="400" alt="cron-sh-script" /><br/> <sub>✅ Cron job script created and deployed with Ansible</sub> </td> <td align="center"> <img src="https://github.com/user-attachments/assets/4ca3d8bc-d242-4559-9425-db2568b2a6e4" width="400" alt="cronjob-postfix-installed" /><br/> <sub>📦 Postfix installed and configured</sub> </td> <td align="center"> <img src="https://github.com/user-attachments/assets/c8ee2945-5e67-46d6-bf1c-7da9efda3662" width="400" alt="cron-job-ran-successfully" /><br/> <sub>📌 Cron ran successfully — simulated output verified</sub> </td> </tr> <tr> <td align="center"> <img src="https://github.com/user-attachments/assets/76378e3e-a61a-46d3-a994-d4a4489c7fcf" width="400" alt="email-cron-test-deployed" /><br/> <sub>📄 Log confirms cron test deployed successfully</sub> </td> <td align="center"> <img src="https://github.com/user-attachments/assets/695569c8-a0b6-428c-b17f-d02ab157dbd0" width="400" alt="postfix-outcome" /><br/> <sub>📬 Postfix handled simulated mail output without errors</sub> </td> <td></td> </tr> </table>




📸 Project Screenshots & Outputs

The screenshots throughout this README document real-time terminal output, Ansible task results, and visual confirmations of the REDCap web app working correctly.

📂 Screenshot categories:
- Infrastructure provisioning
- Ansible installation and role setup
- Apache and MariaDB configuration
- REDCap app deployment
- CRON and Postfix test logs


## ⚠️ Why We Didn’t Use the Real REDCap Build

The REDCap application requires a licensed download from Vanderbilt University, which cannot be redistributed publicly.

For the purpose of this demo, I used a **dummy ZIP file** to simulate a REDCap build. This allowed me to:

- Test automation logic
- Simulate real folder structure
- Verify Apache, PHP, and MariaDB integration

The automation would work identically with the real build in a licensed production environment. The only difference is that official REDCap files include a setup wizard (`install.php`) which wasn’t included in this demo.



## 🐞 Errors I Faced & How I Solved Them

Throughout the deployment, I encountered several real-world issues:

- **Database connection errors:**  
  - `Error 1130: not allowed to connect`  
    🔧 Solution: Ensured MySQL `bind-address` allowed connections and added correct privileges for Ansible.
  - `Connection refused` during `check_db.php` test  
    🔧 Solution: Verified `mysqld` was running and socket access was enabled.

- **Root password idempotency issue:**  
  🔧 Solution: Created a flag file (`/etc/mysql/.root_password_set`) to ensure the root password was only set once.

- **Apache document root override issue:**  
  🔧 Solution: Added correct `DocumentRoot` and `<Directory>` block in the Apache config template.

- **Cron script permission denied:**  
  🔧 Solution: Ensured `/var/log/redcap_cron_test.log` was writable by `www-data` and set correct `chmod`.

- **Postfix testing limitations in simulation:**  
  🔧 Solution: Replaced actual email with a dummy mail script to simulate job completion.

These challenges helped reinforce debugging skills and made the automation more production-ready.



### 🧠 What I Learned from This Project

- Provisioning cloud infrastructure using Terraform  
- Creating production-ready folder structure for DevOps projects  
- Automating server configuration with Ansible (Apache, MariaDB, REDCap)  
- Securely connecting to EC2 using SSH  
- Using CRON and Postfix for scheduled jobs and simulated email  
- Writing modular Ansible roles and templates  
- Debugging PHP, permissions, and DB connection issues  
- Documenting and version-controlling projects with Git and GitHub



