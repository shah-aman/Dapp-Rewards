# from logging import log
from pymongo import MongoClient
from settings import MONGO_URI, DB_NAME
import datetime
class MongoAPI:
    def __init__(self, data):
        self.client = MongoClient(MONGO_URI)

        database = DB_NAME
        collection = data['collection']
        cursor = self.client[database]
        self.collection = cursor[collection]
        self.data = data


    def delete(self, data):
        filt = data['Document']
        response = self.collection.delete_one(filt)
        output = {'Status': 'Successfully Deleted' if response.deleted_count > 0 else "Document not found."}
        return output

    def update(self):
        filt = self.data['Filter']
        updated_data = {"$set": self.data['DataToBeUpdated']}
        response = self.collection.update_one(filt, updated_data)
        output = {'Status': 'Successfully Updated' if response.modified_count > 0 else "Nothing was updated."}
        return output

    def read_all(self, filter=None):
        if filter:
            print(filter)
            documents = self.collection.find(filter)

        else:
            documents = self.collection.find()

        list_documents = list(documents)
        return list_documents

    def read(self):
        documents = self.collection.find()
        print(documents)
        output = [{item: data[item] for item in data if item != '_id'}
                  for data in documents]
        return output

    def write(self, data):
        print('Writing Data')
        new_document = data['Document']
        
        response = self.collection.insert_one(new_document)

        return response
