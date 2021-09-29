Stetson Handlers
###################

The most common use-case for a handler in Stetson is to interact with the workflow enforced by Cowboy which encourages the "*correct*" usage of HTTP status codes by a series  of optional callbacks. Whereas in Cowboy these optional callbacks are functions  sat on a module, in Stetson these are functions added  inline as part of the building process.

The handler for this in Cowboy is `cowboy_rest <https://ninenines.eu/docs/en/cowboy/2.6/manual/cowboy_rest/>`_ for which there is the equivalent module `Stetson.Rest <https://pursuit.purerl.fun/packages/erl-stetson/docs/Stetson.Rest>`_.

A very basic route handler could look like this:

.. code:: haskell

  import Stetson.Types (routeHandler)
  
  book :: Isbn -> SimpleStetsonHandler (Maybe Book)
  book id = 
    routeHandler (\req -> do
                            book <- BookLibrary.findByIsbn id
                            Rest.initResult req book)
      # Rest.contentTypesProvided (\req state -> Rest.result (jsonWriter : nil) req state)
    where
      jsonWriter = tuple2 "application/json" (\req state -> Rest.result (writeJSON state) req state)

We need an init of some sort, for which we're using *routeHandler*, and then we're providing the contentTypesProvided callback (which maps to content_types_provided in Cowboy) which further provides the callbacks to serve those content types (in this case just application/json along with a callback that just calls writeJSON on the current state).

The eagle-eyed reader will notice the use of *SimpleStetsonHandler*, which is an alias for *StetsonHandler msg state*  where msg is fixed to type 'Unit' as Rest handlers have no reason to be receiving messages of any kind.

As many of these callbacks can be provided as are needed, some examples provided below.

.. code:: haskell

    allowedMethods :: (Req -> state -> Effect (RestResult (List HttpMethod) state))
    resourceExists :: (Req -> state -> Effect (RestResult Boolean state))
    malformedRequest :: (Req -> state -> Effect (RestResult Boolean state))
    allowMissingPost :: (Req -> state -> Effect (RestResult Boolean state))
    contentTypesAccepted :: (Req -> state -> Effect (RestResult (List (Tuple2 String (AcceptHandler state))) state))
    contentTypesProvided :: (Req -> state -> Effect (RestResult (List (Tuple2 String (ProvideHandler state))) state))
    deleteResource :: (Req -> state -> Effect (RestResult Boolean state))
    isAuthorized :: (Req -> state -> Effect (RestResult Authorized state))
    movedTemporarily :: (Req -> state -> Effect (RestResult MovedResult state))
    movedPermanently :: (Req -> state -> Effect (RestResult MovedResult state))
    serviceAvailable :: (Req -> state -> Effect (RestResult Boolean state))
    previouslyExisted :: (Req -> state -> Effect (RestResult Boolean state))
    forbidden :: (Req -> state -> Effect (RestResult Boolean state))
    isConflict :: (Req -> state -> Effect (RestResult Boolean state))

These map almost directly onto their similarly named counterparts in `Cowboy <https://ninenines.eu/docs/en/cowboy/2.8/manual/cowboy_rest/>`_ which means the documentation for the latter can be read to determine their usage. A complete workflow is provided in the Cowboy docs for the various responses that will be sent as a result of nagivating these callbacks.

While building a single rest handler in Cowboy and/or Stetson can be quite a verbose process, the nature of everything being a function in Stetson means that once commonality has been identified in a user application it is very easy to start composing handlers out of common functions (for example, a resourceExists could operate over a state of Maybe a and return true or false, there is no need to write this multiple times).


