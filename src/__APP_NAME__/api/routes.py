"""Defines the routes for the API"""

from flask import Flask, jsonify
from celery.result import AsyncResult

from ..worker import tasks
from .. import config as cfg

FLASK = Flask(__name__)


@FLASK.route("/")
def api_version():
    """API version 'tag-hash'"""
    return cfg.API_VERSION

@FLASK.route("/api/reverse/<str_to_reverse>")
def reverse_string(str_to_reverse):
    task = tasks.reverse.delay(str_to_reverse)
    return jsonify({"task_id": task.id})

@FLASK.route("/api/task/<task_id>")
def get_task_status(task_id):
    task = AsyncResult(task_id, app=tasks.CELERY)
    
    response = {
        'task_id': task_id,
        'state': task.state,
        'message': task.result if task.state == 'SUCCESS' else str(task.info) if task.state == 'FAILURE' else 'Task is processing'
    }
    
    return jsonify(response)