import os

import tornado.web
from tornado.web import StaticFileHandler

from rosbridge_library.capabilities.advertise import Advertise
from rosbridge_library.capabilities.publish import Publish
from rosbridge_library.capabilities.subscribe import Subscribe
from rosbridge_library.capabilities.advertise_service import AdvertiseService
from rosbridge_library.capabilities.unadvertise_service import UnadvertiseService
from rosbridge_library.capabilities.call_service import CallService

from server_handlers import Bridge, Pkgs


class MainHandler(tornado.web.RequestHandler):
    def get(self):
        self.write("Hello, world")

def url_path_join(*args):
    return "/" + "/".join(args)

def setup_handlers(web_app, base_url="http://0.0.0.0", url_path="ros"):
    host_pattern = ".*$"

    # Prepend the base_url so that it works in a jupyterhub setting
    route_bridge = url_path_join(url_path, "bridge")
    route_pkgs = url_path_join(url_path, "pkgs/(.*)")

    print("route_pkgs: ", route_pkgs)

    handlers = [
        (route_bridge, init_bridge()),
        (route_pkgs, Pkgs),
    ]

    web_app.add_handlers(host_pattern, handlers)

def init_bridge():
    # Get the glob strings and parse them as arrays.
    Bridge.topics_glob = []
    Bridge.services_glob = ["/rosapi/*"]
    Bridge.params_glob = []

    Subscribe.topics_glob = Bridge.topics_glob
    Advertise.topics_glob = Bridge.topics_glob
    Publish.topics_glob = Bridge.topics_glob
    AdvertiseService.services_glob = Bridge.services_glob
    UnadvertiseService.services_glob = Bridge.services_glob
    CallService.services_glob = Bridge.services_glob
    Bridge.start()
    return Bridge