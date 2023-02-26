from flask import Response, request
from app.social_rewards.service import SocialRewardsService
from flask_restful import Resource, Api
from app import app
from http import HTTPStatus
import json

api = Api(app)
api.init_app(app)

@api.resource('/social-rewards')
class SocialReward(Resource):

    def get(self):
        # TODO: implement this
        return

    def post(self):
        request_json = request.json
        print('SocialReward request: ', request_json)

        try:
            response = SocialRewardsService().create_social_reward(request_json)

            if response:
                return Response(response=json.dumps(response),
                            status=HTTPStatus.CREATED,
                            content_type='application/json')
            else:
                return Response(response="reward_id not found",
                        status=HTTPStatus.NOT_FOUND,
                        content_type='application/json')
        except Exception as e:
            print(e)
            return Response(status=HTTPStatus.INTERNAL_SERVER_ERROR)


@app.route('/get_all_social_rewards/<wallet_address>')
def get(wallet_address):
    if not wallet_address:
        return Response(status=HTTPStatus.BAD_REQUEST)

    response = dict()
    try:
        response = SocialRewardsService().get_all_active_social_rewards("twitter", wallet_address)

    except Exception as e:
        print("Exception in get_all_active_social_rewards: ", e)
        return Response(status=HTTPStatus.INTERNAL_SERVER_ERROR)

    if response:
        return Response(
            response=json.dumps(response,sort_keys=True, default=str),
            status=HTTPStatus.OK,
            content_type='application/json')
    else:
        return Response(response="No data found get_all_active_social_rewards",
                    status=HTTPStatus.NOT_FOUND,
                    content_type='application/json')

