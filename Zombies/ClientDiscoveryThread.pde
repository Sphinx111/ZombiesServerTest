public class ClientDiscoveryThread extends Thread {
  
  DatagramSocket clientDiscoverer;
  int bufLength = 128;
  String DISCOVER_SEARCH_CODE = "Hello Mr Magoo";
  String DISCOVER_REPLY_CODE = "You're in the right place!";
  int SEARCH_SOCKET = 15132;
  
  public ClientDiscoveryThread() {
    super("Zombies");
  }
  
  @Override
  public void run() {
    try {
      //keep a socket open to listen to all UDP traffic being broadcast to specified port.
      clientDiscoverer = new DatagramSocket();
      clientDiscoverer.setBroadcast(true);
      
      byte[] sendData = DISCOVER_SEARCH_CODE.getBytes();
      
      //try default 255.255.255.255 address first
      try {
        DatagramPacket packet = new DatagramPacket(sendData,sendData.length,InetAddress.getByName("255.255.255.255"),SEARCH_SOCKET);
        clientDiscoverer.send(packet);
        System.out.println(getClass().getName() + ">>> SEARCH PACKET SENT TO 255.255.255.255");
      } catch (Exception e) { 
      }
      
      //broadcast the message over all network interfaces...
      Enumeration interfaces = NetworkInterface.getNetworkInterfaces();
      
      while (interfaces.hasMoreElements()) {
        NetworkInterface networkInterface = (NetworkInterface)interfaces.nextElement();
        if (networkInterface.isLoopback() || !networkInterface.isUp()) {
          continue; //don't want to broadcast to loopback interface
        }
        
        for (InterfaceAddress interfaceAddress : networkInterface.getInterfaceAddresses()) {
          InetAddress broadcast = interfaceAddress.getBroadcast();
          if (broadcast == null) {
            continue;
          }
          try {
            DatagramPacket sendPacket = new DatagramPacket(sendData,sendData.length, broadcast, SEARCH_SOCKET);
            clientDiscoverer.send(sendPacket);
          } catch (Exception e) {
          }
          System.out.println(getClass().getName() + ">>> SEARCH PACKET SENT TO " + broadcast.getHostAddress() + " via Interface: " + networkInterface.getDisplayName());
        }
        System.out.println(getClass().getName() + ">>> FINISHED SENDING SEARCH PACKETS ON ALL INTERFACES, NOW AWAITING RESPONSE");
      }
      
      //get the response
      byte[] recvBuf = new byte[bufLength];
      DatagramPacket recvPacket = new DatagramPacket(recvBuf, recvBuf.length);
      clientDiscoverer.receive(recvPacket);
      
      //WE HAVE A RESPONSE!
      System.out.println(getClass().getName() + ">>> Search Response received from " + recvPacket.getAddress().getHostAddress());
      String message = new String(recvPacket.getData()).trim();
      if (message.contains(DISCOVER_REPLY_CODE)) {
        String[] pieces = message.split("/");
        int serverPort = Integer.parseInt(pieces[1]);
        client.setServerAddressAndPort(recvPacket.getAddress(),serverPort);
      }
      
      clientDiscoverer.close();
      
    } catch (Exception e) {
      e.printStackTrace();
    }
  }
  
  
}