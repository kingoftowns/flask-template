# Flask / Celery / Redis template

This document outlines how to use the `flask-app` codebase.

## The Basics

### Requirements

This project requires a Linux development environment.  In order to successfully build and run this application, the following are required:

* Docker
* Docker Compose
* Python 3.6+
* pip
* pip-tools

Additionally, the project has been instrumented to be debugged through Microsoft's [VS Code](https://code.visualstudio.com/).  This is optional.  However, much of this document assumes you will be developing and debugging in VS Code.

### Setting Up Your Development Environment

Once you have pulled down the source, you will need to set up your virtual environment...

```bash
# Create virtual environment
python3 -m venv .venv

# Activate virtual environment
source ./.venv/bin/activate

# Generate dependencies file
pip-compile --no-index --output-file=requirements.txt src/flask-app/requirements.in

# Install dependencies
pip install -r requirements.txt
```

### Starting the Application

There are convenient `Make` targets that you can use to control your application.  Here is a summary of the most common targets...

```bash
# Start the application.  Will make it available on localhost port 80.
make up

# Stop the application
make down

# Take down the application and bring it back up
make reload

# Run tests
make test

# Run linter
make lint

# Run static type-check
make type-check
```

There are some convenience targets as well, for interacting with the various components of the application...

```bash
# Connect a bash terminal session to the API server container
make connect-api

# Connect a bash terminal session to the Celery worker container
make connect-worker

# Connect a bash terminal session to the Redis queue container
make connect-queue

# Tail the logs of the API server container
make log-api

# Tail the logs of the Celery worker container
make log-worker

# Tail the logs of the Redis queue container
make log-queue
```

Finally, for a list of all of the available `Make` targets, you can execute the following...

```bash
# See available make targets with a short description
make help
```

## Debugging

This section will guide you with how to set up local debugging of the application using Microsoft's [VS Code](https://code.visualstudio.com/).

You will notice that there is a `.vscode/` folder checked in at the root of this project.  Typically, these IDE-specific configuration files are left out of source.  However, these are generic enough to be portable across users, and provide value by more easily enabling local debugging.

You can choose to debug your application in any way you see fit, but the rest of this section will focus on how to debug your application using VS Code.

### Prerequisites

In order to successfully debug your application using VS Code, the following extensions must be installed...

* [Python](https://marketplace.visualstudio.com/items?itemName=ms-python.python)
* [Docker](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-docker)

### Debugging Running Application

Using VS Code, we can set up local debugging of the running application.  In order to do this, you will need to follow 3 steps:

1. Run Redis queue
2. Start local debugging of Flask
3. Start local debugging of Celery

The following 3 steps are described below.  Once you do these, you will be able to insert breakpoints anywhere in the application and debug them through VS Code's integrated debugging environment.

#### Run Redis Queue

In order for the Flask API server and the Celery worker to communicate, they pass tasks through a Redis queue.  The easiest way to start that process is to use the convenience `make` target, `start-queue`...

```bash
make start-queue
```

That will start a Redis server that is available locally at `http://localhost:6379`.

**Note**: If you have your application running locally already, either through `make up` or `make reload`, starting the queue in this way will take down your application.

#### Debugging the Flask API Server

If you go to the "Run" panel (can hit `Ctrl`+`Shift`+`D`) of your VS Code instance, you should see a drop-down that presents the various debug profiles you can execute.  Select `Local: Flask` and hit the play button next to it to start debugging the application.  This will build and run the Flask application locally and make it available on `http://localhost:8080`.

You will see output that looks similar to this...

```
(.venv) user@dev-machine ~/flask-template (branch) $  env CELERY_BROKER_URL=redis://queue:6379/0 FLASK_APP=src/flask-app/run FLASK_ENV=development FLASK_DEBUG=0 PYTHONIOENCODING=UTF-8 PYTHONUNBUFFERED=1 /home/user/flask-template/.venv/bin/python /home/user/.vscode-server/extensions/ms-python.python-2020.3.71659/pythonFiles/ptvsd_launcher.py --default --client --host localhost --port 42600 -m flask run --no-debugger --no-reload --host=0.0.0.0 --port=8080 
 * Tip: There are .env or .flaskenv files present. Do "pip install python-dotenv" to use them.
 * Serving Flask app "src/flask-app/run"
 * Environment: development
 * Debug mode: off
 * Running on http://0.0.0.0:8080/ (Press CTRL+C to quit)
 ```

You can now set and hit breakpoints in the Flask routes.

### Debugging the Celery Worker

Additionally in the "Run" panel drop-down, you should see another option called `Local: Celery`.  Select that configuration and hit the play button.  Similarly, this will start a debug process, but for your Celery worker.

You will see output that looks similar to this...

```
(.venv) user@dev-machine ~/flask-template/src (branch) $  env CELERY_BROKER_URL=redis://localhost:6379/0 PYTHONIOENCODING=UTF-8 PYTHONUNBUFFERED=1 /home/user/flask-template/.venv/bin/python /home/user/.vscode-server/extensions/ms-python.python-2020.3.71659/pythonFiles/ptvsd_launcher.py --default --client --host localhost --port 45545 -m celery -A flask-app.worker.tasks worker -P solo --loglevel=info 
 
 -------------- celery@dev-machine v4.4.2 (cliffs)
--- ***** ----- 
-- ******* ---- Linux-4.4.0-53-generic-x86_64-with-Ubuntu-16.04-xenial 2020-04-16 12:20:54
- *** --- * --- 
- ** ---------- [config]
- ** ---------- .> app:         tasks:0x7fdf612a0c10
- ** ---------- .> transport:   redis://localhost:6379/0
- ** ---------- .> results:     disabled://
- *** --- * --- .> concurrency: 40 (solo)
-- ******* ---- .> task events: OFF (enable -E to monitor tasks in this worker)
--- ***** ----- 
 -------------- [queues]
                .> celery           exchange=celery(direct) key=celery
                

[tasks]
  . flask-app.worker.tasks.reverse

[2020-04-16 12:20:54,444: INFO/MainProcess] Connected to redis://localhost:6379/0
[2020-04-16 12:20:54,452: INFO/MainProcess] mingle: searching for neighbors
[2020-04-16 12:20:55,478: INFO/MainProcess] mingle: sync with 1 nodes
[2020-04-16 12:20:55,478: INFO/MainProcess] mingle: sync complete
[2020-04-16 12:20:55,496: INFO/MainProcess] celery@dev-machine ready.
```

You can now set and hit breakpoints in the Celery tasks.