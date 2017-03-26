import java.net.DatagramSocket;
import java.net.InetAddress;
import java.net.DatagramPacket;

class ServerModule extends Thread {
  
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
  
  DatagramSocket clientListener;
  DatagramSocket broadcastListener;
  InetAddress wildCardAddress;
  InetAddress myAddress;
  float serverTickCount = 0;
  int SERVER_HANDSHAKE_CODE = 55122031;
  int LISTENING_PORT = 51218;
  
  DiscoveryThread discoverThread;
  
  ArrayList<LinkedClient> clientsLinked = new ArrayList<LinkedClient>();
  int nextClientID = 0;
  
  private int bufLength = 512;
  
  public ServerModule() {
    super("Zombies");
    try {
      //Set up a socket at port 4445
      clientListener = new DatagramSocket(LISTENING_PORT);
      System.out.println("ServerModule listening on port: " + clientListener.getPort());
      
      //set up discovery thread
      discoverThread = new DiscoveryThread();
      discoverThread.start();
      
    } catch (Exception e) {
      e.printStackTrace();
      if (clientListener != null) {clientListener.close();}
    }
  }
  
  void run() {
    if (clientListener == null) {
      return;
    }
    System.out.println("ServerModule listening on port: " + clientListener.getPort());
    while (true) {
      try {
          byte[] bufIn = new byte[bufLength];  
          DatagramPacket packetIn = new DatagramPacket(bufIn, bufIn.length);
          clientListener.receive(packetIn);
          PacketType received = checkPacketType(packetIn);
          if (received == PacketType.CLIENT_REGISTER) {
            addLinkedClient(packetIn.getAddress(),packetIn.getPort());
            byte[] toSend = prepareJoinData(packetIn);
            DatagramPacket sendPacket = new DatagramPacket(toSend,toSend.length,packetIn.getAddress(),packetIn.getPort());
            clientListener.send(sendPacket);
          } else if (received == PacketType.CLIENT_INPUT) {
            acceptClientInput(packetIn);
          }
          
          
          //acceptClientInput(packetIn);        
      } catch (Exception e) {
        e.printStackTrace();
      }
    }
    
  }
  
  byte[] prepareJoinData(DatagramPacket packetIn) {
    int clientID = -1;
    for (LinkedClient client : clientsLinked) {
      if (client.address == packetIn.getAddress() && client.port == packetIn.getPort()) {
        clientID = client.id;
      }
    }
    StringBuilder builder = new StringBuilder();
    String line0 = "SERVER_JOINDATA" + "%";
      builder.append(line0);
    String line1 = clientID + "/" + serverTickCount + "%";
      builder.append(line1);
    String line2 = mapHandler.name + "/" + "nothing" + "%"; 
      builder.append(line2);
    String line3 = "NO_CHANGE" + "%";
      builder.append(line3);
    String stringToSend = builder.toString();
    return stringToSend.getBytes();
  }
  
  void createWorldUpdateData (Actor[] actorsMoved, MapObject[] doorsMoved) {
    //Prepare data for sending to clients.
  }
  
  void acceptClientInput(DatagramPacket packetIn) {
    String dataIn = new String(packetIn.getData());
    String[] dataLines = dataIn.split("%");
    String[] lineOne = dataLines[1].split("/");
    int playerID = Integer.parseInt(lineOne[0]);
    int clientTickCount = Integer.parseInt(lineOne[1]);
    
    //if (serverTickCount > clientTickCount + 5) {  //filter out packets that are too far behind
    
    //line Two contains player keyboard Inputs labelled with tickCount. initially will only have one input set per packet
    String[] lineTwo = dataLines[2].split("/");
    int inputTickCount = Integer.parseInt(lineTwo[0]); //currently unused
    String inputString = lineTwo[1];
    int W = inputString.charAt(0);
    int A = inputString.charAt(1);
    int S = inputString.charAt(2);
    int D = inputString.charAt(3);
    // line three contains snapshot of mouse Data (are they firing, and at what angle).
    String[] lineThree = dataLines[3].split("/");
    float angle = Float.parseFloat(lineThree[0]);
    int boolClick = Integer.parseInt(lineThree[1]);
    
    //send commands to the client's player
      actorControl.setAngle(playerID,angle);
      if (boolClick > 0) {
        actorControl.shoot(playerID);
      }
      for (int i = 0; i < W; i++) {
        actorControl.moveForward(playerID);
      }
      for (int i = 0; i < A; i++) {
        actorControl.moveLeft(playerID);
      }
      for (int i = 0; i < S; i++) {
        actorControl.moveBackward(playerID);
      } 
      for (int i = 0; i < D; i++) {
        actorControl.moveRight(playerID);
      }
    //}
  }
  
  void addLinkedClient(InetAddress address, int port) {
    
    if (nextClientID > actorControl.MAX_PLAYER_COUNT) {
      nextClientID = 0;
    }
    boolean sendJoinData = false;
    boolean clientIsNew = true;
    boolean clientIsReconnected = false;
    int replaceID = -1;
     for (LinkedClient existing : clientsLinked) {
       if (existing.address == address && existing.port == port) {
         clientIsNew = false;
       } else if (existing.address == address) {
         replaceID = existing.id;
         clientIsReconnected = true;
       }
     }
     
     LinkedClient toAdd = new LinkedClient(address,port,nextClientID);
     if (clientIsNew) {
       clientsLinked.add(toAdd);
       nextClientID += 1;
     } else if (clientIsReconnected) {
       toAdd = new LinkedClient(address,port,replaceID);
       clientsLinked.add(toAdd);
     }
     
  }
  
  PacketType checkPacketType(DatagramPacket packetIn) {
    String dataIn = new String(packetIn.getData());
    String[] dataLines = dataIn.split("%");
    String type = dataLines[0];
    if (type.equals("CLIENT_REGISTER")) {
      return PacketType.CLIENT_REGISTER;
    } else if (type.equals("CLIENT_INPUT")) {
      return PacketType.CLIENT_INPUT;
    } else {
      return PacketType.NO_TYPE;
    }
  }
  
  void communicateWorldState() {
    try {
      
      
    } catch (Exception e) {
      e.printStackTrace();
    }
    
  }
  
  
  
}

class LinkedClient {
  
 int id;
 InetAddress address;
 int port;
  
 public LinkedClient(InetAddress address, int port,int id) {
   this.address = address;
   this.port = port;
   this.id = id;
 }
  
}