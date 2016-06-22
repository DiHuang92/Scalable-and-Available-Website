package rpc;

import java.io.IOException;
import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.InetAddress;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Arrays;
import java.util.Date;

import servelet.SessionServelet;
import session.Session;

public class RpcServer {
	
	/*
	 * method to listen to RPC client side request and call session read or write method to deal with request
	 * @param empty
	 * @return void
	 */
	public void rpcCallRequestProcessor() throws IOException, ParseException, NumberFormatException{
		
		DatagramSocket rpcSocket = new DatagramSocket(Utils.PROJECT1_PORT_NUMBER);

		while(true){

			byte[] inBuf = new byte[Utils.MAX_PACKET_LENGTH];
			byte[] outBuf = null;
			DatagramPacket recvPkt = new DatagramPacket(inBuf, inBuf.length);
			
			rpcSocket.receive(recvPkt);
		
			//execute the following code when there arrives a packet
			
			if( recvPkt.getAddress()!=null ){
				System.out.println("A packet has arrived at server!");
				InetAddress returnAddr = recvPkt.getAddress();
				int returnPort = recvPkt.getPort();
				String requestInfo = new String(recvPkt.getData());
				System.out.println("Server : received String is "+requestInfo);
				String[] requestInfoArray = requestInfo.split(Utils.SPLITTER);
				String operationCode = requestInfoArray[1];
			    
				//call sessionRead method or sessionWrite method according to Operation Code
				switch(operationCode){
				
					case Utils.OPERATION_SESSION_READ:
						System.out.println("RPC server received read requset");
						outBuf = sessionRead(requestInfo);
						break;
					case Utils.OPERATION_SESSION_WRITE:
						outBuf = sessionWrite(requestInfo);
						break;	
				}
				
				DatagramPacket sentPkt = new DatagramPacket(outBuf, outBuf.length, returnAddr, returnPort);
				rpcSocket.send(sentPkt);	
			}
			
		}
	}
	
	
	/*
	 * method to search the session and return message
	 * @param String info
	 * @return byte[]
	 */
	public byte[] sessionRead(String info) throws ParseException, NumberFormatException{
		
		//information extraction
		
		String[] infoArray = info.split(Utils.SPLITTER);
		String callID = infoArray[0];
		String sessionID = infoArray[2]; 
		Long requestVersionNumber = Long.parseLong(infoArray[3].trim());
		System.out.println("Server received versionNumber "+requestVersionNumber);
		String readMessage="";

		
		// there will always be matched session,cookie hasn't time out, session won't time out
		
		Session session = SessionServelet.getSessionByIDVersion(sessionID, String.valueOf(requestVersionNumber));

		if(session == null) {
			return Utils.NOT_FOUND.getBytes();
		}
		
		readMessage = session.getMessage();
		
		byte[] outBuf = new byte[Utils.MAX_PACKET_LENGTH];
		
		outBuf = String.join(Utils.SPLITTER, Arrays.asList(callID, sessionID, String.valueOf(requestVersionNumber), readMessage, 
				 String.valueOf(SessionServelet.getServID()) )).getBytes();
		System.out.println("outBuf is : " + outBuf);
		return outBuf;
	}
	
	/*
	 * method to write session message and return writing operation result in array
	 * @param String info
	 * @return byte[]
	 */
	 public byte[] sessionWrite(String info) throws ParseException{
		 System.out.println("In RPC server write, info string is:"+ info);
		 String[] infoArray = info.split(Utils.SPLITTER);
		 String requestCallID = infoArray[0];
		 String sessionID = infoArray[2];
		 Long requestVersionNumber = Long.parseLong(infoArray[3]);
		 String message = infoArray[4];	
		 String expireTime = infoArray[5].trim();
		 
		 System.out.println("Generate Date input "+expireTime);
		 SimpleDateFormat formatter = new SimpleDateFormat(Utils.DATE_TIME_FORMAT);
		 Date expireDateTime = formatter.parse(expireTime);
		 Session newSession;

		 newSession = new Session(sessionID, message);
         newSession.setVersionNumber(requestVersionNumber);
		 newSession.setMessage(message);
		 newSession.setExpireTime(expireDateTime);
		 SessionServelet.addSessionToTable(newSession);

		 String result = String.join(Utils.SPLITTER, Arrays.asList(requestCallID, SessionServelet.getServID()+"",
				 newSession.getSessionID(), ""+newSession.getVersionNumber() ));
		 System.out.println("Returned message from sessionWrite() is: " + result);
		 return result.getBytes();
	 }
	 
	
}
