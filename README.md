# SNA Project - Alert Management System

This project provides an easy-to-deploy Alert Management System based on Suricata, Elasticsearch, Filebeat, and Grafana. The infrastructure is containerized with Docker and Docker Compose for quick setup and portability.

## Project Overview

The system captures network traffic, processes events through Suricata IDS (Intrusion Detection System), collects logs via Filebeat, stores and indexes them with Elasticsearch, and visualizes the data in Grafana.

Additionally, this project integrates bWAPP, a vulnerable web application, which is used for demonstrating real-time security alerts triggered by scanning tools such as Nmap and Nuclei.

## Components

* **Suricata:** Network threat detection
* **Elasticsearch:** Log storage and indexing
* **Filebeat:** Log shipping from Suricata to Elasticsearch
* **Grafana:** Data visualization and alert monitoring
* **bWAPP:** Vulnerable web application for security testing

## Requirements

* Docker and Docker Compose installed on the host
* Git for cloning the repository

## Quick Start

### Step 1: Clone the repository

```bash
git clone https://github.com/Rozanalex/SNA-project.git
cd SNA-project
```

### Step 2: Deploy the Alert Management Infrastructure

Run the containers:

```bash
docker compose up -d
```

### Step 3: Launch bWAPP

Navigate to the `bwapp` directory and launch the vulnerable web app:

```bash
cd bwapp
docker compose up -d
```

### Step 4: Access Grafana Dashboard

* Visit Grafana at: [http://localhost:3000](http://localhost:3000)
* Default credentials: `admin/secret`

### Step 5: Generate Security Events (Alerts)

From another host, run scans using `nuclei` and `nmap` against your bWAPP instance:

* Nuclei scan:

  ```bash
  nuclei -u http://<TARGET_IP>:8080
  ```

* Nmap scan:

  ```bash
  nmap -sV -A <TARGET_IP>
  ```

Replace `<TARGET_IP>` with the IP address of the bWAPP instance.

### Step 6: Visualize Alerts in Grafana

Return to Grafana to monitor and visualize security alerts and events.

## Project Structure

```
SNA-project/
├── docker-compose.yml
├── grafana/
│   ├── dashboards/        # Grafana dashboards JSON
│   └── provisioning/      # Grafana data source and dashboard provisioning
├── filebeat/
│   └── filebeat.yml       # Configuration for log shipping
├── suricata/
│   ├── suricata.yaml      # Suricata configuration
│   └── rules/
│       └── local.rules    # Custom Suricata rules
└── bwapp/
    └── docker-compose.yml # bWAPP setup
```

## Troubleshooting

If Grafana dashboards do not display data:

* Verify that containers are running:

  ```bash
  docker compose ps
  ```
* Inspect logs for potential issues:

  ```bash
  docker compose logs suricata
  docker compose logs filebeat
  ```
