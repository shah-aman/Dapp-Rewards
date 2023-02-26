from app.db.mongo_db import MongoAPI
from datetime import datetime
import uuid


def get_uuid():
    return str(uuid.uuid4());

db_data = {
    "collection": "social_rewards"
}

class SocialReward:
    def create(self, data):
        social_reward = {
            "social_reward_id": get_uuid(),
            'created_at': datetime.now(),
            'updated_at': datetime.now(),
            "reward": data["reward"],
            "tweet_id": data["tweet_id"],
        }
        print(social_reward)
        mongo_api = MongoAPI(db_data)
        response = mongo_api.write({"Document": social_reward})
        return response

    def get_all(self, filter=None):
        mongo_api = MongoAPI(db_data)

        if filter:
            print("filter: ",filter)
            response = mongo_api.read_all(filter)
        else:
            response = mongo_api.read_all()

        return list(response)


    # def get_all_by_filter(self, filter):
    #     mongo_api = MongoAPI(db_data)

    #     return response