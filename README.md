Auction Demo
=============
This repo will contain a demonstration of concurrency in erlang by running serveral auctions 
in parallel.
One auction process shall be responsible for initiating a request to client processes.
The client processes can return with a number.
The client with the highest number shall win.
There can be many auction processes all with their own clients running concurrently.

Compiling and Running
=============
First time running, do
make deps
to fetch all dependencies and compile the modules

After this you can do
make demo

which will run the application.

If open a web browser at http://127.0.0.1:8888
you will have a web interface were you can set the number of auctions and the
number of clients per auction.

The web ui will have one red circle for each auction.  As each auction gets a response
the blue bar will be incremented for each response.



