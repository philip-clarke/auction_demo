Auction Demo
=============
This repo will contain a demonstration of concurrency in erlang using an auction model.
One auction process shall be responsible for initiating a request to client processes.
The client processes can return with a number.
The client with the highest number shall win.
There can be many auction processes all with their own clients running concurrently.

During the auction a web page will display the process of the ongoing auctions.
The web page will use a bar chart created by d3.js.
The web page will get updated by the auction process via a web socket.
