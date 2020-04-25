"""Defines the tasks for our API workers"""

from celery import Celery

from .. import config as cfg
from ..api import routes

CELERY = Celery('tasks', broker=cfg.CELERY_BROKER_URL)

@CELERY.task
def reverse(string_to_reverse):
    """Reverses a given string"""
    return string_to_reverse[::-1]