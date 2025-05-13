from fastapi import FastAPI
from random import choice
import uvicorn

app = FastAPI()

OPTIONS = ["Investments", "Smallcase", "Stocks", "buy-the-dip", "TickerTape"]

@app.get("/api/v1")
async def get_random_string():
    return {"random_string": choice(OPTIONS)}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8081)