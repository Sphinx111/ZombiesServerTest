public class DiscoveryThread extends Thread {
  
  DatagramSocket discoverySocket;
  int socketNum = 15132;
  int bufLength = 128;
  String DISCOVER_SEARCH_CODE = "Hello Mr Magoo";
  String DISCOVER_REPLY_CODE = "You're in the right place!";
  
  public DiscoveryThread () {
    super("Zombies");
  }
  
  @Override
  public void run() {
    try {
      //keep a socket open to listen to all UDP traffic being broadcast to specified port.
      discoverySocket = new DatagramSocket(socketNum, InetAddress.getByName("0.0.0.0"));
      discoverySocket.setBroadcast(true);
      
      while (true) {
        System.out.println(getClass().getName() + ">>>Ready to receive packet broadcasts");
        
        //Receive a packet (receive method only triggers if a packet is actually received, otherwise it blocks the function)
        byte[] recvBuf = new byte[bufLength];
        DatagramPacket packet = new DatagramPacket(recvBuf, recvBuf.length);
        discoverySocket.receive(packet);
        
        //announce received packet in console:
        System.out.println(getClass().getName() + ">>>Discovery Packet received from: " + packet.getAddress().getHostAddress());
        System.out.println(getClass().getName() + ">>>Packet data: " + new String(packet.getData()));
        
        //Once packet received, evaluate it:
        String message = new String(packet.getData()).trim();
        if (message.equals(DISCOVER_SEARCH_CODE)) {
          //if the message is valid, send a response.
          //provide proper port to use to client after reply code:
          String dataToSend = DISCOVER_REPLY_CODE + "/" + server.LISTENING_PORT;
          
          byte[] standardResponse = new String(dataToSend).getBytes();
          DatagramPacket responsePacket = new DatagramPacket(standardResponse,standardResponse.length,packet.getAddress(),packet.getPort());
          discoverySocket.send(responsePacket);
        }
        
      }
      
    } catch (Exception e) {
      e.printStackTrace();
    }
  }
  
  
}