from fastapi import FastAPI

# 🔐 Auth
from app.routes.auth import router as auth_router

# 🎟️ Booking
from app.routes.booking import router as booking_router

# 🤖 Recommendation
from app.routes.recommendation import router as recommendation_router

# 📊 Analytics
from app.routes.analytics import router as analytics_router

# 🎬 Movies
from app.routes.movie_router import router as movie_router

# 🎟️ Events
from app.routes.event_router import router as event_router


app = FastAPI()


# 🔗 Register all routers
app.include_router(auth_router)
app.include_router(booking_router)
app.include_router(recommendation_router)
app.include_router(analytics_router)
app.include_router(movie_router)
app.include_router(event_router)