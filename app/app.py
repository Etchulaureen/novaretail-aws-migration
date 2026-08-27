from flask import Flask, jsonify
import os, socket
app=Flask(__name__)
@app.get('/')
def index(): return f"<h1>NovaRetail AWS Migration Lab</h1><p>Status: healthy</p><p>Host: {socket.gethostname()}</p><p>Environment: {os.getenv('APP_ENV','lab')}</p>"
@app.get('/health')
def health(): return jsonify(status='ok',host=socket.gethostname())
if __name__=='__main__': app.run(host='0.0.0.0',port=8080)
