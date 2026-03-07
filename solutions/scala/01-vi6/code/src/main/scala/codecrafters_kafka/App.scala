package codecrafters_kafka

import java.io.IOException
import java.net.{ServerSocket, Socket}

object Main extends App {
  var clientSocket: Socket = null
  val port = 9092

  try {
    val serverSocket = new ServerSocket(port)
    // Since the tester restarts your program quite often, setting SO_REUSEADDR
    // ensures that we don't run into 'Address already in use' errors
    serverSocket.setReuseAddress(true)
    // Wait for connection from client.
    clientSocket = serverSocket.accept()
  } catch {
    case e: IOException => System.out.println("IOException: " + e.getMessage)
  } finally {
    try {
      if (clientSocket != null) {
        clientSocket.close()
      }
    } catch {
      case e: IOException => System.out.println("IOException: " + e.getMessage)
    }
  }
}
