# 🚀 DevOps CI/CD Pipeline for React Application

A complete end-to-end DevOps project demonstrating how to build, test, containerize, and deploy a React application using modern DevOps tools and practices.

This project automates the entire software delivery lifecycle using Jenkins, Docker, Kubernetes, and AWS.

---

# 📌 Project Overview

This project implements a CI/CD pipeline that automatically:

* Pulls source code from GitHub
* Installs project dependencies
* Builds the React application
* Creates a Docker image
* Pushes the image to Docker Hub
* Deploys the application to a Kubernetes cluster
* Verifies successful deployment

The goal is to simulate a production-ready deployment pipeline used by modern software teams.

---

# 🛠️ Tech Stack

* React.js
* Node.js
* Jenkins
* Docker
* Docker Hub
* Kubernetes (K3s)
* Git & GitHub
* Linux (Ubuntu)
* Nginx

---

# 📂 Project Structure

```text
.
├── public/
├── src/
├── Dockerfile
├── Jenkinsfile
├── deployment.yaml
├── service.yaml
├── package.json
├── package-lock.json
└── README.md
```

---

# ⚙️ Prerequisites

Before running this project, ensure the following tools are installed:

* Node.js 22+
* npm
* Docker
* Jenkins
* kubectl
* Kubernetes (K3s)
* Git

---

# 📥 Installation

Clone the repository:

```bash
git clone https://github.com/<your-username>/<repository>.git
```

Move into the project directory:

```bash
cd <repository>
```

Install dependencies:

```bash
npm install
```

---

# ▶️ Run Locally

Start the development server:

```bash
npm start
```

Open your browser:

```
http://localhost:3000
```

---

# 🧪 Run Tests

```bash
npm test
```

---

# 🏗️ Production Build

```bash
npm run build
```

The optimized production build will be generated inside the `build/` directory.

---

# 🐳 Docker

Build the Docker image:

```bash
docker build -t react-app .
```

Run the container:

```bash
docker run -d -p 80:80 react-app
```

---

# ☸️ Kubernetes Deployment

Deploy the application:

```bash
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
```

Check deployment status:

```bash
kubectl get deployments
kubectl get pods
kubectl get svc
```

---

# 🔄 Jenkins CI/CD Pipeline

The Jenkins pipeline performs the following stages:

1. Checkout source code from GitHub
2. Install npm dependencies
3. Run tests
4. Build the React application
5. Build Docker image
6. Push Docker image to Docker Hub
7. Deploy to Kubernetes
8. Verify deployment

---

# 📦 Available npm Scripts

| Command         | Description                               |
| --------------- | ----------------------------------------- |
| `npm start`     | Starts the development server             |
| `npm test`      | Runs the test suite                       |
| `npm run build` | Builds the application for production     |
| `npm run eject` | Ejects the Create React App configuration |

---

# 📸 Future Improvements

* GitHub Webhook integration
* SonarQube code quality analysis
* Trivy container image scanning
* Prometheus monitoring
* Grafana dashboards
* ArgoCD GitOps deployment
* Helm charts
* Multi-environment deployments (Dev, QA, Prod)

---

# 📖 Learning Objectives

This project demonstrates practical experience with:

* CI/CD pipeline design
* Docker containerization
* Kubernetes deployments
* Jenkins Pipeline (Declarative)
* Linux administration
* GitHub integration
* Kubernetes Services and Deployments
* Infrastructure automation
* DevOps best practices

---

# 👨‍💻 Author

**Chanchal Khatua**

M.Tech (Computer Science & Engineering), NIT Agartala

Interested in DevOps, Cloud Engineering, Site Reliability Engineering (SRE), and Platform Engineering.

---

# 📄 License

This project is intended for learning and portfolio purposes. Feel free to fork and customize it for your own use.
