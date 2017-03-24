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
  boolean listening = false;
  float serverTickCount;
  int SERVER_HANDSHAKE_CODE = 55122031;
  int BROADCAST_PORT = 50121;
  
  ArrayList<LinkedClient> clientsLinked = new ArrayList<LinkedClient>();
  int nextClientID = 0;
  
  private int bufLength = 512;
  
  public ServerModule() {
    super("Zombies");
    try {
    myAddress = InetAddress.getByName(InetAddress.getLocalHost().getHostAddress());
    wildCardAddress = InetAddress.getByName("0.0.0.0");
    //Set up a socket at port 4445
    clientListener = new DatagramSocket();
    broadcastListener = new DatagramSocket(BROADCAST_PORT);
    broadcastListener.setBroadcast(true);
    System.out.println("ServerModule listening on port: " + clientListener.getPort());
    listening = true;
    } catch (Exception e) {
      e.printStackTrace();
      if (clientListener != null) {clientListener.close();}
      if (broadcastListener != null) {broadcastListener.close();}
    }
  }
  
  void run() {
    if (clientListener == null) {
      return;
    }
    System.out.println("ServerModule listening on port: " + clientListener.getPort());
    while (listening) {
      try {
        byte[] bufInput = new byte[bufLength];
        DatagramPacket packetIn;
        InetAddress address;
        int port;
        String dString = null;
        
        //receive blind broadcasts
        byte[] broadcastIn = new byte[bufLength];
        DatagramPacket packetB = new DatagramPacket(broadcastIn, bufLength);
        broadcastListener.receive(packetB);
        registerNewClient(packetB);
        
        //receive request
        packetIn = new DatagramPacket(bufInput,bufLength);
        clientListener.receive(packetIn);
        address = packetIn.getAddress();
        port = packetIn.getPort();
        PacketType inType = checkPacketType(packetIn);
        if (inType == PacketType.CLIENT_REGISTER) {
          //registerNewClient(packetIn);
        } else if (inType == PacketType.CLIENT_INPUT) {
          acceptClientInput(packetIn);
        }
        
      } catch (Exception e) {
        e.printStackTrace();
      }
    }
    
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
  
  
  void registerNewClient(DatagramPacket packetIn) throws Exception {
    boolean addClient = true;
    for (LinkedClient client : clientsLinked) {
      if (client.address == packetIn.getAddress()) {
        addClient = false;
      }
    }
    if (addClient) {
      //Check that this is actually a valid packet from the zombies game and not random junk
      byte[] packetSafe = new byte[bufLength];
      String[] safePieces = new String(packetSafe).split("/");
      if (Integer.parseInt(safePieces[0]) == SERVER_HANDSHAKE_CODE) {
        while (actorControl.players[nextClientID] != null) {
          System.out.println("clientID in use, searching for new available ID");
          nextClientID++;
          if (nextClientID == actorControl.MAX_PLAYER_COUNT) {
            nextClientID = 0;
          }
        }
        byte[] packetData = packetIn.getData();
        String dataStr = new String(packetData);
        String[] dataPieces = dataStr.split("/");
        int portToUse = Integer.parseInt(dataPieces[1]);
        LinkedClient newClient = new LinkedClient(packetIn.getAddress(),portToUse,nextClientID);
        clientsLinked.add(newClient);
        actorControl.addNewHumanPlayer(newClient.id);
        //send server identity and handshake to the new client.
        sendServerDetailsTo(newClient);
        
        nextClientID += 1;
        if (nextClientID == actorControl.MAX_PLAYER_COUNT) {
          nextClientID = 0;
        }
      }
    }
  }
  
  void sendServerDetailsTo(LinkedClient client) throws Exception {
    byte[] welcomeMsg = new byte[bufLength];
    String welcome = ""+SERVER_HANDSHAKE_CODE+"/";
    welcomeMsg = welcome.getBytes();
    DatagramPacket serverWelcomePacket = new DatagramPacket(welcomeMsg,bufLength,client.address,client.port);
    clientListener.send(serverWelcomePacket);
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