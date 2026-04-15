# NSISC Meet Ops & Recruit Matrix 🏊‍♂️📊
**[🚀 View Live Application Here](https://nsisc-demo-project.vercel.app/)**

An enterprise-grade sports analytics and meet management dashboard designed specifically for the New South Intercollegiate Swimming Conference (NSISC). Built with a high-contrast, defense-tech inspired interface, this platform tracks live championship scoring, handles complex tie-breaking mathematics, and projects the exact point impact of prospective recruits using real-time course conversions.

![React](https://img.shields.io/badge/React-20232A?style=for-the-badge&logo=react&logoColor=61DAFB)
![TypeScript](https://img.shields.io/badge/TypeScript-007ACC?style=for-the-badge&logo=typescript&logoColor=white)
![Ruby on Rails](https://img.shields.io/badge/Ruby_on_Rails-CC0000?style=for-the-badge&logo=ruby-on-rails&logoColor=white)
![GraphQL](https://img.shields.io/badge/GraphQL-E10098?style=for-the-badge&logo=graphql&logoColor=white)

## 🚀 Key Features

* **Dynamic Meet Scoring Engine:** Automatically calculates standard 16-place NCAA scoring. Features an advanced mathematics engine that detects ties, averages point distributions, and updates team standings in real-time.
* **Recruit Impact Simulator:** Inject "Virtual Assets" (recruits) into the live database. The engine instantly recalculates the entire meet, demonstrating exactly how many points a recruit would steal from rival teams and where they would place in the finals.
* **Automated Course Conversion:** Built-in NCAA D2 Men's conversion factors. Input times in Short Course Meters (SCM) or Long Course Meters (LCM), and the engine automatically converts to Short Course Yards (SCY) rounded to the nearest hundredth.
* **NCAA Standard Tracking:** Automatically flags times against official NCAA D2 A-Cut and B-Cut qualifying standards.
* **Tactical UI/UX:** A Shield.ai-inspired dark mode aesthetic featuring deep slate backgrounds, high-contrast cyan accents, monospaced data rendering, and collapsible team matrices.

---

## 🛠 Tech Stack

### Frontend (Client)
* React.js (Vite)
* TypeScript
* CSS (CSS-in-JS inline styling)

### Backend (API)
* Ruby on Rails (API Mode)
* PostgreSQL Database
* GraphQL Endpoint Structure
* Nokogiri & HTTParty (Web Scraping / Data Ingestion)

---

## ⚙️ Installation & Setup

### Prerequisites
Ensure you have the following installed on your local machine:
* Node.js & npm
* Ruby (v3.0+)
* PostgreSQL

### 1. Backend Setup (`secureframe_api`)
Navigate to the backend directory and set up the Rails API.

```bash
cd secureframe_api

# Install Ruby dependencies
bundle install

# Create the database, load schema, and inject the 2026 Championship Seed Data
rails db:create db:migrate db:seed

# Start the Rails server (runs on port 3000 by default)
rails server
```

### 2. Frontend Setup (`secureframe_client`)
Open a new terminal window, navigate to the frontend directory, and start the Vite development server.

```bash
cd secureframe_client

# Install Node dependencies
npm install

# Start the development server
npm run dev
```

The application will now be running at `http://localhost:5173`. 

---

## 📖 Usage Guide

**1. Viewing Standings** Upon loading, the dashboard fetches the live `db/seeds.rb` data from the Rails backend via GraphQL and renders the current championship standings.

**2. Expanding Rosters** Click on any Team Banner to expand their tactical roster, displaying every swimmer's stacked individual races, placement, and points scored.

**3. Running Projections** Use the **Recruit Projection Input** panel to simulate a new swimmer. Enter their name, target team, event, course (SCY/SCM/LCM), and time.

**4. Analyzing Impact** Click "Execute Simulation." The recruit will appear in the top panel and as a highlighted "Virtual Asset" in the team rosters, shifting the live score of the entire meet based on their placement.

---

## 🧠 Data Architecture Note
The **Recruit Simulator** operates entirely in the React frontend memory state (`useState` and `useMemo`). This allows coaches to rapidly test dozens of hypothetical scenarios without permanently polluting the official PostgreSQL championship records.
```
