Docker
######

A docker file is provided in the  `demo-ps <https://github.com/id3as/demo-ps>`_ Purerl project that will allow for the building and execution of the project.

This is not by any means a "best practises" Docker development environment, I don't actually have a clue what a "best practises" Docker development environment would look like but I know this is not it (It's massive, for a start). This has been thrown together to make it easy to run the demo_ps project without having to manually install the tools required which has got to be a good thing.

This is definitely a good starting point for learning what tools are needed for a development environment and where to get them from (replace linux with macos in those download URLs and you're pretty good to go, binaries are available for most platforms across these projects)

Pull requests happily accepted if anybody wants to replace the docker workflow/files with something a little more appropriate.


.. literalinclude:: /demo-ps/Dockerfile
  :language: docker


For convenience, the scripts *./build_docker_image.sh* and *./run_docker_image.sh* are provided, the project can be built therefore with

.. code-block:: bash

  # Build the actual docker image
  ./build_docker_image.sh

  # Compile the project
  ./run_docker_image.sh rebar3 compile

  # Build a release
  ./run_docker_image.sh rebar3 release

  # Run the whole shebang
  ./run
