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

@app.route('/data/<coordinates>', methods=['GET'])
def get_data(coordinates):
    # Get the data for the given coordinates
    data = data_store.get(coordinates)

    if data is None:
        return jsonify({'message': 'No data found for these coordinates'}), 404

    return jsonify(data), 200

if __name__ == '__main__':
    app.run(debug=True)
