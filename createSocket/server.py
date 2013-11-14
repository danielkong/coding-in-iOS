from twisted.internet import reactor
from twisted.internet.protocol import Factory, Protocol

class IphoneChat(Protocol):
  def connectionMade(self):
    self.factory.clients.append(self)
    print "a client connected, named as ", self.factory.clients

  def connectionLost(self, reason):
    self.factory.clients.remove(self)

factory = Factory()
factory.clients = []
factory.protocol = IphoneChat
reactor.listenTCP(81, factory)
print "Iphone Chat server started!"
reactor.run()
