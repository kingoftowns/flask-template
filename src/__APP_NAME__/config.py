"""Configuration values for the application"""

import os

API_VERSION = "__API_VERSION__"

CELERY_BROKER_URL = os.getenv('CELERY_BROKER_URL', 'redis://localhost:6379/0')