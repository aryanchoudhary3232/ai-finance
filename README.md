# AI Finance Platform - Personal Finance & Budgeting Application

[![Next.js](https://img.shields.io/badge/Next.js-15-black?style=flat&logo=next.js)](https://nextjs.org/)
[![Docker](https://img.shields.io/badge/Docker-Containerized-blue?style=flat&logo=docker)](https://www.docker.com/)
[![Nginx](https://img.shields.io/badge/Nginx-Reverse%20Proxy-green?style=flat&logo=nginx)](https://nginx.org/)
[![AWS EC2](https://img.shields.io/badge/AWS-EC2%20Deployed-orange?style=flat&logo=amazon-aws)](https://aws.amazon.com/ec2/)
[![Prisma](https://img.shields.io/badge/Prisma-PostgreSQL-2D3748?style=flat&logo=prisma)](https://www.prisma.io/)
[![Clerk](https://img.shields.io/badge/Clerk-Authentication-6C47FF?style=flat&logo=clerk)](https://clerk.com/)
[![ArcJet](https://img.shields.io/badge/ArcJet-Rate%20Limiting-red)](https://arcjet.com/)
[![Inngest](https://img.shields.io/badge/Inngest-Background%20Jobs-black)](https://www.inngest.com/)
[![Resend](https://img.shields.io/badge/Resend-Email%20Service-black)](https://resend.com/)

A modern, production-grade AI-powered financial management platform designed for tracking accounts, analyzing category-wise spending, automating recurring transactions, scanning receipts with Google Gemini, and managing budgets with background event processing.

🔗 **Live Demo:** [ai-finance-ruby.vercel.app](https://ai-finance-ruby.vercel.app/)

---

## 🌟 Key Features

- **AI Receipt Scanning**: Integrated Google Gemini API to extract merchant, total amount, date, description, and expense category from uploaded receipt images, pre-filling transaction forms automatically.
- **Account & Budget Management**: Multi-account support (Checking, Savings, Credit) with real-time balance tracking, budget threshold warnings, and category-wise spending analytics.
- **Background Automation (Inngest)**: Event-driven workflows for recurring transaction processing, scheduled budget alerts, and monthly financial email summaries.
- **Security & Rate Limiting (ArcJet)**: Shielded endpoints with token-bucket rate limiting, bot protection, and request validation.
- **Email Notifications (Resend)**: Automated transaction confirmations, monthly budget tracking alerts, and expense reports built using React Email.
- **Containerized & Production Ready**: Dockerized with multi-stage standalone builds, production Nginx reverse proxy configuration, and deployment scripts for AWS EC2 Linux instances.

---

## 🏗️ Architecture & Technology Stack

| Layer | Technologies |
| :--- | :--- |
| **Frontend & SSR** | Next.js 15 (App Router), React 19, Tailwind CSS, Shadcn UI, Recharts |
| **Backend & APIs** | Next.js Server Actions, Zod validation, Next.js Middleware |
| **Database & ORM** | PostgreSQL, Prisma ORM (4 core models: User, Account, Transaction, Budget) |
| **Auth & Security** | Clerk Authentication, ArcJet Rate Limiting & Bot Detection |
| **AI & Automation** | Google Gemini API (Vision receipt parsing), Inngest (Background cron/queues) |
| **Notifications** | Resend API, React Email templates |
| **DevOps & Infra** | Docker (multi-stage), Docker Compose, Nginx Reverse Proxy, AWS EC2, PM2, systemd |

---

## 🚀 Quick Start (Local Development)

### 1. Clone and Install Dependencies

```bash
git clone https://github.com/aryanchoudhary3232/ai-finance.git
cd ai-finance
npm install
```

### 2. Configure Environment Variables

Copy `.env.example` to `.env` and fill in your API credentials:

```bash
cp .env.example .env
```

### 3. Initialize Prisma Database

```bash
# Generate Prisma client
npx prisma generate

# Apply migrations to PostgreSQL
npx prisma migrate dev --name init
```

### 4. Run Development Server

```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) in your browser.

---

## 🐳 Running with Docker & Docker Compose

The application is containerized with a production multi-stage Docker build utilizing Next.js standalone mode and non-root execution.

### Start All Services (Next.js Web + PostgreSQL + Nginx)

```bash
# Build and start services in background
docker compose up -d --build

# View runtime logs
docker compose logs -f web

# Stop services
docker compose down
```

Services exposed:
- **Nginx Reverse Proxy**: [http://localhost:80](http://localhost:80)
- **Next.js Web Container**: [http://localhost:3000](http://localhost:3000)
- **PostgreSQL Database**: `localhost:5432`

---

## ☁️ AWS EC2 & Linux Production Deployment Guide

### Step 1: Launch EC2 Instance
- **AMI**: Ubuntu 22.04 LTS or 24.04 LTS
- **Instance Type**: `t3.small` or `t3.medium` recommended
- **Security Group Inbound Rules**:
  - `SSH` (port 22) - restricted to your IP
  - `HTTP` (port 80) - `0.0.0.0/0`
  - `HTTPS` (port 443) - `0.0.0.0/0`

### Step 2: Run Automated Server Setup

SSH into your EC2 instance and run the server provisioning script:

```bash
# Clone the repository
git clone https://github.com/aryanchoudhary3232/ai-finance.git /var/www/ai-finance
cd /var/www/ai-finance

# Run EC2 Linux initialization (installs Docker, Nginx, UFW, fail2ban)
chmod +x deploy/ec2-setup.sh
./deploy/ec2-setup.sh
```

### Step 3: Configure Production Environment Variables

```bash
cp .env.example .env
nano .env
# Fill in Clerk keys, PostgreSQL production URL, Gemini, Inngest, ArcJet, and Resend keys
```

### Step 4: Run Production Deployment Script

```bash
chmod +x scripts/deploy.sh
./scripts/deploy.sh
```

The script automatically:
1. Pulls the latest code
2. Executes `prisma migrate deploy`
3. Builds the optimized Next.js Docker image
4. Restarts containers with zero downtime
5. Validates application health

### Step 5: Process Management with PM2 (Optional Alternative)

If running directly on the host with Node.js rather than Docker:

```bash
npm run build
pm2 start ecosystem.config.js
pm2 save
```

### Step 6: Configure SSL with Let's Encrypt (Certbot)

To attach your custom domain with free SSL:

```bash
sudo apt install -y certbot python3-certbot-nginx
sudo certbot --nginx -d yourdomain.com -d www.yourdomain.com
```

---

## 🗄️ Database Management & Prisma Commands

```bash
# Push schema changes during development
npx prisma db push

# Create and apply a migration
npx prisma migrate dev --name <migration_name>

# Apply pending migrations in production
npx prisma migrate deploy

# Open Prisma Studio to inspect database records
npx prisma studio
```

---

## 🛡️ License

This project is licensed under the MIT License.
