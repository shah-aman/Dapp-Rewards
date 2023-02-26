from app.social_rewards.models import SocialReward
from app.rewards.models import Reward
from datetime import datetime
from app.rewards.const import RewardStatus

class SocialRewardsService:

    def get_all_active_social_rewards(self, social_platform, wallet_address):
        """
        not expired
        not reedemed
        """
        print('get_all_active_social_rewards, platform: ', social_platform, wallet_address)
         # "expiry_datetime" : {
            #     "$gte" : datetime.now()
            # },
        all_social_rewards = SocialReward().get_all(
            filter={

            "reward.wallet_address": {
                "$eq": wallet_address
            },
            "reward.status": {
                "$eq": RewardStatus.NOT_REDEEMED.name
            }
        }
            )


        return all_social_rewards

    def create_social_reward(self, request_data):
        """
        social_reward = {
            "reward_id": data["reward_id"],
            "tweet_id": data["tweet_id"]
        }
        """

        social_reward_data = dict()
        social_reward_data["tweet_id"] = request_data["tweet_id"]

        reward = Reward().get(request_data["reward_id"])
        # print("got reward",reward, type(reward), type(reward[0]))
        if not (reward):
            return

        social_reward_data["reward"] = reward[0]
        # print("social_reward_data", social_reward_data)
        social_reward = SocialReward().create(social_reward_data)
        # print('created')
        response = {
            'status': 'Successfully Inserted Tweet and Reward',
            'document_id': str(social_reward.inserted_id)
        }

        return response