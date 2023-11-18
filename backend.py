from flask import Flask, request, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

# Our in-memory data store
data_store = {}

@app.route('/data', methods=['POST'])
def add_data():
    # Get the JSON data from the request
    json_data = request.get_json()

    # Extract the fields
    coordinates = json_data.get('coordinates')
    name = json_data.get('name')
    age = json_data.get('age')
    severity_status = json_data.get('severity_status')
    situation = json_data.get('situation')

    # Store the data
    data_store[coordinates] = {
        'name': name,
        'age': age,
        'severity_status': severity_status,
        'situation': situation
    }

    return jsonify({'message': 'Data added successfully'}), 201

@app.route('/data', methods=['GET'])
def get_all_data():
    # Return all data
    return jsonify(data_store), 200

if __name__ == '__main__':
    app.run(debug=True)
