from flask import Response, request
from app.rewards.service import RewardsService
from flask_restful import Resource, Api
from app import app
import json
from http import HTTPStatus

api = Api(app)

# TODO: add autherization
@api.resource('/reward')
class Reward(Resource):
    def get(self, id):
        print(id)
        response = RewardsService().get_reward(id)
        if response:
            return Response(response=json.dumps(response),
                        status=HTTPStatus.OK,
                        content_type='application/json')
        return Response(status=HTTPStatus.INTERNAL_SERVER_ERROR)

    def get(self):
        response = dict()
        try:
            response = RewardsService().get_all_rewards()
        except Exception as e:
            print("Exception in get all: ", e)
            return Response(status=HTTPStatus.INTERNAL_SERVER_ERROR)

        if response:
            print('****', type(response))

            return Response(
                response=json.dumps(response,sort_keys=True, default=str),
                status=HTTPStatus.OK,
                content_type='application/json')
        else:
            return Response(response="No data found",
                        status=HTTPStatus.NOT_FOUND,
                        content_type='application/json')

    def post(self):
        """
        reward object: {
            'reward_id': get_uuid(),
            'created_at': datetime.now(),
            'updated_at': datetime.now(),
            'wallet_address': data['wallet_address'],
            'no_of_tokens':  data['no_of_tokens'],
            'status': data['status'],
            'event': data['event']
        }
        """
        # validate request
        request_json = request.json

        print('Reward request: ', request_json)

        wallet_address = request_json.get("wallet_address")
        expiry_datetime = request_json.get("expiry_datetime")
        no_of_tokens = request_json.get("no_of_tokens")
        event = request_json.get("event")

        if (not all([wallet_address, expiry_datetime, no_of_tokens, event])):
            return Response(status=HTTPStatus.BAD_REQUEST)

        request_data = {
            "wallet_address": wallet_address,
            "no_of_tokens": no_of_tokens,
            "expiry_datetime": expiry_datetime,
            "event": event
        }

        response = RewardsService().create_reward(request_data)

        if response:
            return Response(response=json.dumps(response),
                        status=HTTPStatus.CREATED,
                        content_type='application/json')
        return Response(status=HTTPStatus.INTERNAL_SERVER_ERROR)

# api.add_resource(Drop, '/drop/<int:id>', '/drop')
# api.add_resource(Drop, '/drop/<int:id>')
# api.add_resource(Drop, '/drop')