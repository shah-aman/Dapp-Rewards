import os
from flask import Flask

project_dir = os.path.dirname(os.path.abspath(__file__))

app = Flask(__name__)


from app.rewards.controller import *
from app.social_rewards.controller import *
from app.airdrop.controller import *
