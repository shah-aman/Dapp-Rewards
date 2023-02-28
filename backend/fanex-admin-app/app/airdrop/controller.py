
from flask import Response, request
from app.airdrop.service import AirDropService
from flask_restful import Resource, Api
from app import app
import json
from http import HTTPStatus

api = Api(app)

@api.resource('/airdrop')
class AirDropController(Resource):
    def post(self):
        request_json = request.json
        print('airdrop request: ', request_json)

        response = AirDropService().assign_token_to_wallet(request_json)
        error_msg = {
            "status": "error"
        }
        if response:

            return Response(
                response=json.dumps(response,sort_keys=True, default=str),
                status=HTTPStatus.OK,
                content_type='application/json')
        else:
            return Response(response=json.dumps(error_msg),
                        status=HTTPStatus.NOT_FOUND,
                        content_type='application/json')
