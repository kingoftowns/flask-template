"""Defines the routes for the API"""

from flask import Flask, request, abort

from ..worker import tasks
from .. import config as cfg

FLASK = Flask(__name__)


@FLASK.route("/")
def api_version():
    """API version 'tag-hash'"""
    return cfg.API_VERSION

@FLASK.route("/api/reverse/<str_to_reverse>")
def reverse_string(str_to_reverse):
    tasks.reverse.delay(str_to_reverse)
    return "Task added!"