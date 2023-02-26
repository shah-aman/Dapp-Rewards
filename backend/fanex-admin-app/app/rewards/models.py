from datetime import datetime
from app.db.mongo_db import MongoAPI
from bson.objectid import ObjectId
import uuid

class BaseModel:
    # TODO: add common fields here date time etc
    pass

def get_uuid():
    return str(uuid.uuid4());

db_data = {
    "collection": "rewards"
}

class Reward:

    def create(self, data):
        reward = {
            'reward_id': get_uuid(),
            'created_at': datetime.now(),
            'updated_at': datetime.now(),
            'expiry_datetime': data['expiry_datetime'],
            'wallet_address': data['wallet_address'],
            'no_of_tokens':  data['no_of_tokens'],
            'status': data['status'],
            'event': data['event']
        }
        mongo_api = MongoAPI(db_data)
        response = mongo_api.write({"Document": reward})
        return response

    def get(self, id):
        print("id", id)
        mongo_api = MongoAPI(db_data)
        response = mongo_api.read_all({"reward_id": {"$eq": id}})
        return response
