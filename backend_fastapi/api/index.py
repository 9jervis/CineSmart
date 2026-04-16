import os
import sys

# Ensure backend_fastapi is importable when Vercel runs this function from api/.
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if BASE_DIR not in sys.path:
    sys.path.insert(0, BASE_DIR)

from app.main import app  # ASGI app exposed for Vercel Python runtime
