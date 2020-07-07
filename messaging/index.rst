Messaging
=========

Messaging. Without it, Erlang wouldn't work very well. Many concepts are modelled as processes which do things in response to messages, and a lot of APIs revolve around starting up a process and waiting for messages to come back from it (as well as further coordinating that process by sending messages to it).

This is great, but in a typed world we can't just be flinging any old messages around the show - we need to up front specify what messages we will be receiving and what we'll be sending. Thankfully the problem of components sending typed messages about the place has been solved several times in platforms like `Elm <https://elm-lang.org/>`_ and frameworks like `Halogen <https://github.com/purescript-halogen/purescript-halogen>`_ and being long time users of both of these it is no surprise that the patterns and libraries that have emerged in Purerl borrow several key concept from them.

In general, a module that's modelled as a process will define two message types - the one they're planning on receiving and the one that they're sending.  In order to send a message from Sender to Receiver, a function will be provided by Receiver that will lift the outgoing type into the appropriate incoming type and send on its behalf. This is typically then given to the Sender as part of subscription or setup.

Subscribing to Incoming messages (pseudo-example)
*************************************************

.. code-block:: haskell

  -- Our 'receive' message type
  data Msg = Tick
           | SomethingHappened
           | MessageReceived OtherModule.Msg



  init :: Effect Unit
  init = 
    -- Subscribing to messages
    self <- Api.self
    OtherModule.sendMessageToMe (\senderMsg -> send self $ MessageReceived senderMsg)

  receiveMessage :: Msg -> State -> Effect State
  receiveMessageg msg state = 
    case msg of
      Tick -> ...
      SomethingHappened -> ..
      MessageReceived msg -> case msg of ...

In gen servers, that receiveMessage would be a *handleInfo*, in Stetson it'd be be an *info* and in other 'process containers' it could be called something else, but in general the pattern will be 'subscribe to messages by passing in a callback', 'receive messages and modify state accordingly' - all nice and typed.


Sending Outgoing Messages (pseudo example)
******************************************

.. code-block:: haskell

  -- Our 'send message type
  data Msg = Hi String String String String
           | AnotherMessage
           | Etc

  sendMessageToMe :: (Msg -> Effect Unit) -> Effect Unit
  sendMessageToMe emitter = emitter $ Hi "bob"


Typically of course we might store that callback only to invoke it when something occurs, or every time something happens; but in this example we send a message right away that ends up in the message box of the Receiver and gets passed into whatever function the process container exposes for that.

Because most APIs therefore boil down to passing in an emitter of type *(msg -> Effect Unit)*, the underlying framework or library in use at that particular time is irrelevant to how that works. Most of the time, the means of doing this is getting a typed *Process msg*, and composing a *send* over the top of it along with the contructor for the appropriate message type coming into the process. 

In the examples in this chapter, we will assume we're inside a Gen Server (Pinto.Gen) and the examples will use Gen.self, which does exactly as above.

* :doc:`Building an emitter <emitters>`
* :doc:`Message Bus <messagebus>`
* :doc:`Monitors <monitors>`
* :doc:`Process (spawn_link) <process>`
* :doc:`Timers <timers>`

.. toctree::
   :hidden:
   :titlesonly:

   emitters
   messagebus
   monitors
   process
   timers





