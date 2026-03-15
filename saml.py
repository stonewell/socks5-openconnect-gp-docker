import http.server
import json
import threading
import logging


class MyRequestHandler(http.server.BaseHTTPRequestHandler):

  def do_POST(self):
    # Read content length and body
    content_length = int(self.headers['Content-Length'])  #
    post_data = self.rfile.read(content_length).decode('utf-8')

    saml_values = {}
    try:
      saml_values = json.loads(post_data)
    except:
      pass

    if len(saml_values) == 0:
      print(f"echo invalid saml values:{post_data}'\\n';")
      print("export INVALID_SAML_VALUES=yes")
    else:
      print('export INVALID_SAML_VALUES=no;')
      for k, v in saml_values.items():
        print(f'export {k}="{v}";')

    # send response
    self.send_response(200)
    self.end_headers()
    self.wfile.write(b"POST received")

    t = threading.Thread(target=self.server.shutdown)
    t.daemon = True
    t.start()

  def log_message(self, format, *args):
    pass

# Run the server
if __name__ == '__main__':
  server = http.server.HTTPServer(('', 7070), MyRequestHandler)
  server.serve_forever()
