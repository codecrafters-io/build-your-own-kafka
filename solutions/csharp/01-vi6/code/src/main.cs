using System.Net;
using System.Net.Sockets;

TcpListener server = new TcpListener(IPAddress.Any, 9092);
server.Start();
server.AcceptSocket(); // wait for client
