"""Configuration values for the application"""

import os

API_VERSION = "0.0.1"

CELERY_BROKER_URL = os.getenv('CELERY_BROKER_URL', 'redis://localhost:6379/0')