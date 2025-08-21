from flask import Flask

app = Flask(__name__)

@app.route('/')
def home():
    return '¡Hola, mundo desde Flask! version 2'

if __name__ == '__main__':
    app.run(debug=True,host='0.0.0.0')
