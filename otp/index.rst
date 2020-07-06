Basic OTP
#########

As we keep uncovering, the basic hello world of an Erlang application isn't as simple or Hackernews friendly as a single file with a http web server in it. 

In order to get something running, we need to

* Write an application entry point
* Tell Erlang where to find that entry point
* Write a supervision tree
* Write some children to go under that tree

Thankfully we can do *almost* all of this in Purescript (telling Erlang where to find the entry point is still writing Erlang, we don't make new applications very often at work so optimising for 'new projects' isn't something we've really focused on thus far).

* :doc:`Application Entry point <entry>`
* :doc:`Supervisor <supervisor>`
* :doc:`Basic gen server <genserver>`
* :doc:`Dynamic Supervision Trees <dynamic_children>`


.. toctree::
   :hidden:
   :titlesonly:

   entry
   supervisor
   genserver
   dynamic_children


