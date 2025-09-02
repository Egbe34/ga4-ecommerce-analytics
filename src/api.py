from fastapi import FastAPI
from pydantic import BaseModel
import joblib, json
import pandas as pd
from pathlib import Path

app = FastAPI(title="GA4 Funnel Conversion API", version="1.0")

MODEL_PATH = Path("models/purchase_rf.joblib")
SCHEMA_PATH = Path("models/expected_cols.json")

model = joblib.load(MODEL_PATH)
expected_cols = json.loads(SCHEMA_PATH.read_text())

CATEGORICALS = ["channel_group", "day_name", "month"]
NUMERICS = ["sessions", "add_to_cart"]

class PredictInput(BaseModel):
    sessions: int
    add_to_cart: int
    channel_group: str
    day_name: str
    month: int

class PredictOutput(BaseModel):
    prediction: int
    probability_purchase: float

@app.get("/")
def home():
    return {"message": "GA4 Funnel Conversion API is live"}

@app.get("/health")
def health():
    return {"status": "ok", "features_expected": len(expected_cols)}

@app.post("/predict", response_model=PredictOutput)
def predict(payload: PredictInput):
    df = pd.DataFrame([payload.dict()])
    df_encoded = pd.get_dummies(df, columns=[c for c in CATEGORICALS if c in df.columns])
    X = df_encoded.reindex(columns=expected_cols, fill_value=0)
    proba = float(model.predict_proba(X)[:, 1][0])
    pred = int(proba >= 0.5)
    return {"prediction": pred, "probability_purchase": proba}
