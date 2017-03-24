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
  boolean listening = false;
  int clientTickCount;
  int myPlayerID = -1;
  InetAddress myAddress;
  InetAddress serverAddress;
  InetAddress broadcastAddress;
  int serverPort;
  int SERVER_HANDSHAKE_CODE = 55122031;
  int BROADCAST_PORT = 50121;
  int myPort = 13551;
  
  private int bufLength = 512;
  
  ServerInfo serverInfo;
  
  public ClientModule() {
    super("Zombies");
    
    try {
    broadcastAddress = getNetworkLocalBroadcastAddressdAsInetAddress();
    myAddress = InetAddress.getByName(InetAddress.getLocalHost().getHostAddress());
    //Set up a socket at port...
    clientSocket = new DatagramSocket(13551,myAddress);
    System.out.println("ServerModule listening on port: " + clientSocket.getPort());
    listening = true;
    } catch (Exception e) {
      e.printStackTrace();
    }
    
  }
  
  void run() {
    if (clientSocket == null) {
      return;
    }
    while (listening) {
      try {
        byte[] bufInput = new byte[bufLength];
        DatagramPacket packetIn;
        InetAddress address;
        int port;
        String dString = null;
        
        //receive request
        packetIn = new DatagramPacket(bufInput,bufLength);
        clientSocket.receive(packetIn);
        address = packetIn.getAddress();
        port = packetIn.getPort();
        PacketType inType = checkPacketType(packetIn);
        if (inType == PacketType.SERVER_JOINDATA) {
          acceptJoinData(packetIn);
        } else if (inType == PacketType.SERVER_UPDATE) {
          acceptTickUpdate(packetIn);
        }
        
        //if we haven't reached a server yet, broadcast blindly...
        if (myPlayerID == -1) {
          DatagramSocket socket = null;
          try {
              socket = new DatagramSocket();
              socket.setBroadcast(true);
              byte[] buffSend = prepareServerHandshake();
              DatagramPacket packet = new DatagramPacket(buffSend, buffSend.length, broadcastAddress, BROADCAST_PORT);
              socket.send(packet);
          } catch (Exception e) {
              e.printStackTrace();
              if(socket != null) try {socket.close();} catch (Exception e1) {}
          }
        } else {
          byte[] someData = preparePlayerInputData(); 
          DatagramPacket packetOut = new DatagramPacket(someData, bufLength, serverAddress, serverPort);
          clientSocket.send(packetOut);
        }
        
        
      } catch (Exception e) {
        e.printStackTrace();
      }
    }
  }
  
  byte[] prepareServerHandshake() {
    byte[] toSend = new byte[bufLength];
    String testString = "" + SERVER_HANDSHAKE_CODE + "/" + myPort + "/";
    toSend = testString.getBytes();
    return toSend;
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
  
  void acceptJoinData(DatagramPacket packetIn) {
    byte[] dataIn = packetIn.getData();
    String dataString = new String(dataIn);
    String dataPieces[] = dataString.split("/");
    if (Integer.parseInt(dataPieces[0]) == SERVER_HANDSHAKE_CODE) {
      serverAddress = packetIn.getAddress();
      serverPort = packetIn.getPort();
    }
  }
  
  void acceptTickUpdate(DatagramPacket packetIn) {
    
  }
  
  PacketType checkPacketType(DatagramPacket packetIn) {
    String dataIn = new String(packetIn.getData());
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

class ServerInfo {
  InetAddress address;
  int port;
  
  
}

public static InetAddress getNetworkLocalBroadcastAddressdAsInetAddress() throws IOException {
    for (Enumeration<NetworkInterface> en = NetworkInterface.getNetworkInterfaces(); en.hasMoreElements();) {
        NetworkInterface intf = en.nextElement();
        if(!intf.getInetAddresses().nextElement().isLoopbackAddress()){
            byte[] quads = intf.getInetAddresses().nextElement().getAddress();
            quads[0] = (byte)255;
            return InetAddress.getByAddress(quads);
        }
    }
    return null;
}