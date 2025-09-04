# GA4 E-commerce Analytics — End-to-End (BI + ML + API + Docker)

A portfolio-ready project that turns the public GA4 sample dataset into **business insights**, **Power BI dashboards**, a **trained ML model**, and a **deployed prediction API** that runs in **Docker** (also published on Docker Hub).



## 1) Business Case & Questions

Use GA4 e-commerce events to improve **funnel conversion** and **channel ROI**.

**Key questions**
- Which channels convert best from **sessions → purchases**?
- How do **sessions, revenue, and conversion** change by **day/week/month**?
- Where are the biggest **drop-offs** in the funnel?
- (ML) Can we **predict purchase propensity** from simple session features?



## 2) Data & ERD

**Source:** BigQuery public dataset  
`bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`

**Semantic model**
- `dim_date (date_pk, year, month, week, day_name)`
- `dim_channel (channel_key, channel_group, source, medium)`
- `fact_funnel_by_date_channel (date_pk, channel_key, sessions, add_to_cart, purchases, revenue, conversion_rate, aov)`

**SQL (in `/sql`)**
- `10_dim_date.sql`
- `20_dim_channel.sql`
- `30_fact_funnel_by_date_channel.sql`

**Text ERD (quick view)**
```
dim_date
  └─ PK: date_pk

dim_channel
  └─ PK: channel_key

fact_funnel_by_date_channel
  ├─ PK: (date_pk, channel_key)
  ├─ FK: date_pk → dim_date.date_pk
  └─ FK: channel_key → dim_channel.channel_key
```##  ERD / Schema

The project uses a **star schema**:

- **dim_date** (PK = date_pk)  
- **dim_channel** (PK = channel_key)  
- **fact_funnel_by_date_channel**  
  - FK = date_pk → dim_date  
  - FK = channel_key → dim_channel  
  - Metrics: sessions, add_to_cart, purchases, revenue, conversion_rate  

 Visual ERD:  

![ERD](images/erd.png)




## 3) Analysis (Python)

Notebook: `notebooks/01_eda_kpis.ipynb`

**What it covers**
- Channel performance (sessions, purchases, revenue, conversion rate)
- Time trends (monthly/weekly seasonality)
- Funnel analysis (Sessions → Add to Cart → Purchases)
- Trains a **Random Forest** classifier for purchase propensity

**Exports used by dashboards (created by the notebook)**
- `exports/channel_summary.csv`
- `exports/time_summary.csv`
- `exports/funnel_summary.csv`

---

## 4) Dashboards (Power BI)

File: `dashboard/powerbi/GA4 Dashboard.pbix`

**Pages**
1. **Channel Performance & Conversion**
2. **E-commerce Performance Trends**
3. **E-commerce Funnel Performance**

> (Optional) Add screenshots later in `dashboard/screenshots/` and embed below.

---

## 5) Machine Learning

Model: **RandomForestClassifier** (purchase propensity)

**Example features**
- Numeric: `sessions`, `add_to_cart`
- One-hot categoricals: `channel_group`, `day_name`, `month`

**Artifacts (in `/models`)**
- `purchase_rf.joblib`
- `expected_cols.json`  ← feature columns used at inference time



## 6) Deployed API (FastAPI) + Docker

**Code:** `src/api.py`  
**Local (venv)**
```bash
uvicorn src.api:app --host 127.0.0.1 --port 8000 --reload
# Test
curl http://127.0.0.1:8000/health
```

### Docker (local)
```bash
docker build -t ga4-api .
docker run -p 8000:8000 ga4-api
# Test
curl http://127.0.0.1:8000/health
```

### Docker Hub (pull anywhere)
Image: **graceegbe3/ga4-api:latest**
```bash
docker pull graceegbe3/ga4-api:latest
docker run -p 8000:8000 graceegbe3/ga4-api:latest
# Test
curl http://127.0.0.1:8000/health
curl -X POST http://127.0.0.1:8000/predict   -H "Content-Type: application/json"   -d '{"sessions":3,"add_to_cart":1,"channel_group":"Referral","day_name":"Saturday","month":12}'
```

**Endpoints**
- `GET /health` → service status  
- `POST /predict` → returns `{ "prediction": 0|1, "probability_purchase": float }`

---

## 7) Results & Business Impact

- Top channels by **conversion** and **revenue** identified.
- Largest **funnel drop-off** highlighted (Sessions → Add to Cart, or Cart → Purchase).
- ML surfaces **high-propensity sessions** for remarketing / CRO focus.

---

## 8) Reproduce

1) Clone & set up
```bash
git clone https://github.com/Egbe34/ga4-ecommerce-analytics.git
cd ga4-ecommerce-analytics
python -m venv .venv
# Windows
.venv\Scripts\activate
pip install -r requirements.txt
```

2) Run notebook → generate **exports** & **models**
- Open `notebooks/01_eda_kpis.ipynb`
- Run all cells to create `exports/*` and `models/*`

3) Start API (local)
```bash
uvicorn src.api:app --host 127.0.0.1 --port 8000 --reload
```

4)  Docker
```bash
docker build -t ga4-api .
docker run -p 8000:8000 ga4-api
```


## 9) Slides / Presentation

link(https://docs.google.com/presentation/d/1xsjKvD4WlJ30uXDnL1hznrVu6tIGEO-z/edit?usp=sharing&ouid=101322982193861291493&rtpof=true&sd=true)



## Folder Structure


ga4-ecommerce-analytics/
├─ sql/
├─ notebooks/
├─ exports/
├─ models/
├─ src/
├─ dashboard/
│  └─ powerbi/
├─ docs/
└─ Dockerfile
```
