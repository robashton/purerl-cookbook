Stetson Routing
###############

The first step to take in Stetson once the basic configuration has been sorted out is to define some routes and callbacks to invoke when those routes are matched.

In Cowboy this is expressed as a list of string-based routes along with the modules to fire up when those routes are matched and those modules are then responsible for pulling bindings out of the route along with validation of those bindings. This is inverted somewhat in Stetson as we up front define our routes in an ADT along with the types we expect in them, and *then* map those to the paths that'll handle them in the web server.

The routes
**********

The routes for the demo_ps project can be found in the '*./shared/*' directory as it's handy to also be able to build the routes safely from Purescript client code.

.. literalinclude:: /demo-ps/shared/Routes.purs
  :language: haskell
  :linenos:
  :lines: 13-22

Being a demo project there are a pile of nonsensical routes on this ADT but amongst them we have *Books* and *Book Isbn*. The former being a collection handler for listing the books and the latter (*Book Isbn*) being a route that takes a specific ISBN to look up a book from the database. Note the types being used are actual domain types so we're not simply passing strings around. *Array String* is the equivalent of *[...]* in Cowboy "anything under this path" so we've got that in a couple of places; once for the directory containing all the CSS/JS/etc and one for ensuring that any of the client-side routes will all hit *index.html*.

The next thing to do after defining this ADT is to declare how this type can be mapped to and from the actual paths that will be serving the requests, this uses '`Routing.Duplex <https://github.com/natefaubion/purescript-routing-duplex>`_ which was originally written for Purescript but handily cross-compiles  in Purerl without much fuss. That's quite handy as that means the same package can be used on the client-side to generate correct URLS without lazily concatenating strings or going into restful dances to avoid the need to know urls at all.

.. literalinclude:: /demo-ps/shared/Routes.purs
  :language: haskell
  :linenos:
  :lines: 41-55

If you're unfamiliar with Purescript then these strings might look alarming, rest assured this is compile-time checked against the ADT and typos will not be tolerated. Thanks `SProxy <https://pursuit.purescript.org/packages/purescript-symbols/3.0.0/docs/Data.Symbol>`_.

Turning our ADT into a usable string (and vice versa) is just a case of using code from *routing-duplex*, like so

.. literalinclude:: /demo-ps/shared/Routes.purs
  :language: haskell
  :linenos:
  :lines: 57-

We don't need to worry about the inverse here, because Stetson has support for Routing Duplex built-into it.

Using our routes with Stetson
*****************************

Having defined these routes, we can register them with Stetson using *Stetson.routes* when building our configuration, we use the *Routes.apiRoute* defined above and match up the routes to callbacks that will be invoked when those routes match.

.. literalinclude:: /demo-ps/server/src/BookWeb.purs
  :language: haskell
  :linenos:
  :lines: 65-87

In the case of Book, which was defined as *Book Isbn*, it expects a callback of type (*forall msg state. Isbn -> StetsonHandler msg state*), where msg and  state are entirely down to the handler itself to define. (The bulk of this handler is elided from the example as it's very REST specific).

.. literalinclude:: /demo-ps/server/src/BookWeb.purs
  :language: haskell
  :linenos:
  :lines: 136-143


It's a few steps to get to the point where you have a working dispatcher over routes in Stetson, adding a new route is a case of

* Adding the route to the ADT
* Adding the mapping for the path to the Route with routing-duplex
* Adding a handler for the route in Stetson configuration

The good news is that because it's all then type checked, changing the inputs to handlers or moving routes around isn't a guessing game - with larger projects this is quite a big deal indeed.

