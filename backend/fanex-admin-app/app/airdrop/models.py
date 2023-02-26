from datetime import datetime
from app.db.mongo_db import MongoAPI
from bson.objectid import ObjectId
import uuid

db_data = {
    "collection": "airdrop_audit"
}
class AirDropAudit:

    def create(self, data):

        mongo_api = MongoAPI(db_data)

        response = mongo_api.write(data)
        return response