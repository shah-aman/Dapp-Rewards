from app.db.mongo_db import MongoAPI
from app.rewards.models import Reward
from app.rewards.const import RewardStatus, EVENTS_CONSTANT



db_data = {
    "collection": "rewards"
}
class RewardsService:

    # def __init__(self) -> None:
    #     MongoAPI(db_data)

    def get_all_rewards(self):
        obj1 = MongoAPI(db_data)
        response = obj1.read_all()
        print(response)
        return response

    def get_reward(self, id):
        obj1 = MongoAPI(db_data)
        db_data["id"] = id
        response = obj1.read()
        print(response)
        return response



    def create_reward(self, request_data):

        status = RewardStatus.NOT_REDEEMED.name
        event = EVENTS_CONSTANT.get(request_data['event'])
        request_data['status'] = status
        request_data['event'] = event if event else EVENTS_CONSTANT['default']

        reward = Reward().create(request_data)

        response = {
            'status': 'Successfully Inserted',
            'document_id': str(reward.inserted_id)
        }

        return response
