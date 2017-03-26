import java.net.NetworkInterface;
import java.net.InterfaceAddress;
import java.util.Enumeration;
import java.util.List;

class ClientModule extends Thread {
  
  //Packet definitions and ideal sequence
  //LINE 0 ALWAYS has String name of a PacketType enum. Lines are separated by "%" symbol, data elements separated by "/"
  
  //CLIENT_REGISTER - Packet with some sort of simple code to confirm the packet is part of Zombies game.
  //SERVER_JOINDATA - Server gives the client it's ID, and initial gameState data.
  //                - Line1 - clientID / SERVER_TICK_COUNT
  //                - Line2 - MapToLoad / downloadLink(not in v1)
  //                - Line3 - Changes from defaultMap...
  //CLIENT_INPUT    - Client gives server an update on it's status, including a snapshot of player inputs.
  //                - Line1 - clientID / CLIENT_TICK_COUNT
  //                - [tick,WASD] / [tick,WASD] / [tick,WASD] snapshots
  //                - mouseInput snapshots: [angle,clicked] / [angle,clicked];
  //SERVER_UPDATE   - Gives clients an update on world information.
  //                - Line 1 - SERVER_TICK_COUNT
  //                - Line 2 - customDataStructure for actors - [id,pos,vel,angle] / [id,pos,vel,angle] / [id,pos,vel,angle] / [id,pos,vel,angle]
  //                - Line 3 - customDataStructure for doors - [id,opening/closing] / [id,opening/closing]
  //                - Line 4 - customDataStructure for bullets - [pos,pos];
  
  DatagramSocket clientSocket;
  int clientTickCount;
  int myPlayerID = -1;
  InetAddress serverAddress;
  int serverPort;
  String SERVER_JOIN_QUERY = "CLIENT_READY_FOR_JOINDATA";
  
  ClientDiscoveryThread discoverThread;
  
  int myPort = 13551;
  
  private int bufLength = 512;
  
  public ClientModule() {
    super("Zombies");
    
    try {
      //Set up a socket at random open port...
      clientSocket = new DatagramSocket();
      myPort = clientSocket.getPort();
      System.out.println(getClass().getName() + ">>>listening on port: " + clientSocket.getLocalPort());
      
      //set up discovery thread
      discoverThread = new ClientDiscoveryThread();
      discoverThread.start();
      
    } catch (Exception e) {
      e.printStackTrace();
    }
    
  }
  
  void setServerAddressAndPort (InetAddress serverAddr, int serverPort) {
    serverAddress = serverAddr;
    this.serverPort = serverPort;
  }
  
  void run() {
    if (clientSocket == null) {
      return;
    }
    
    while (true) {
      
      try {
      if (serverAddress != null && myPlayerID == -1) {
        //if we haven't had any joinData, query the server.
        byte[] sendData = SERVER_JOIN_QUERY.getBytes();
        DatagramPacket sendPacket = new DatagramPacket(sendData, sendData.length, serverAddress,serverPort);
        clientSocket.send(sendPacket);
      } else if (serverAddress != null && myPlayerID != -1 && shouldSendUpdate()) {
        //if we have had joinData, check if we need to send an update packet, if so do the following:
      } else {
        //if we don't need to send any updateData, wait for a new packet from server
        byte[] recvData = new byte[bufLength];
        DatagramPacket packetIn = new DatagramPacket(recvData, recvData.length);
        clientSocket.receive(packetIn);
        
        //WAITS HERE ^^ UNTIL WE RECEIVE A NEW PACKET
        PacketType receiveType = checkPacketType(packetIn);
        if (receiveType == PacketType.SERVER_JOINDATA) {
          processJoinData(packetIn);
        } else if (receiveType == PacketType.SERVER_UPDATE) {
          processUpdate(packetIn);
        }
      }
      
      } catch (Exception e) {
        
      }
      
    }
    
  }
  
  boolean shouldSendUpdate() {
    return true; //check if we need to send an update to server this frame;
  }
  
  void processUpdate(DatagramPacket packetIn) {
    //THIS DOES NOTHING YET
  }
  
  void processJoinData(DatagramPacket packetIn) {
    String message = new String(packetIn.getData()).trim();
    String[] lines = message.split("%");
    String line1[] = lines[1].split("/");
    int myNewID = Integer.parseInt(line1[0]);
    int serverTickCount = Integer.parseInt(line1[1]);
    String line2[] = lines[2].split("/");
    String mapName = line2[0];
    
    myPlayerID = myNewID;
    mapHandler.loadMap(mapName);
  }
    
  byte[] preparePlayerInputData() {
    byte[] toSend = new byte[bufLength];
    StringBuilder newString = new StringBuilder("");
    String packetNameType = "CLIENT_INPUT";
      newString.append(packetNameType);
      newString.append("%");
    String thisID = myPlayerID + "";
      newString.append(thisID);
      newString.append("/");
    String tickNow = clientTickCount + "";
      newString.append(tickNow);
      newString.append("%");
    int W = keyHandler.getWInt();
    int A = keyHandler.getAInt();
    int S = keyHandler.getSInt();
    int D = keyHandler.getDInt();
    String keysTick = "" + W+A+S+D;
      newString.append(keysTick);
      newString.append("%");
    float angle = actorControl.player.body.getAngle();
    String angleString = angle+"";
      newString.append(angleString);
      newString.append("/");
    int mouseClick;
    if (mousePressed) {mouseClick = 1;} else {mouseClick = 0;}
    String mouseString = mouseClick + "";
      newString.append(mouseString);
    
    String stringToSend = newString.toString();
    toSend = stringToSend.getBytes();
    
    return toSend;
  }
  
  void acceptTickUpdate(DatagramPacket packetIn) {
    
  }
  
  PacketType checkPacketType(DatagramPacket packetIn) {
    String dataIn = new String(packetIn.getData()).trim();
    String[] dataLines = dataIn.split("%");
    String type = dataLines[0];
    if (type.equals("SERVER_JOINDATA")) {
      return PacketType.SERVER_JOINDATA;
    } else if (type.equals("SERVER_UPDATE")) {
      return PacketType.SERVER_UPDATE;
    } else {
      return PacketType.NO_TYPE;
    }
  }
  

}