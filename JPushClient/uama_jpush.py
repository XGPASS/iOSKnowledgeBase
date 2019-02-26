import jpush as jpush
from conf import app_key, master_secret

_jpush = jpush.JPush(app_key, master_secret)
_jpush.set_logging("DEBUG")

push = _jpush.create_push()

ios_msg = jpush.ios(alert=None, badge="+1", extras={'type':'2'})
# android_msg = jpush.android(alert="Hello, android msg")
push.notification = jpush.notification(alert=u"欢迎使用幸福绿城", ios=ios_msg)
# push.message=jpush.message("content",extras={'k2':'v2','k3':'v3'})
push.options = {"apns_production":False}
push.audience = jpush.audience(
    jpush.registration_id('121c83f7602ae2aa768')
)
push.platform = jpush.platform('ios')
push.send()