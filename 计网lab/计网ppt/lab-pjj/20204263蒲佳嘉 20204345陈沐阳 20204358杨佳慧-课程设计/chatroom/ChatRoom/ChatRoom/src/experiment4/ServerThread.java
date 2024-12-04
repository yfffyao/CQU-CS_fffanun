package experiment4;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.Socket;


//服务器消息发送线程
public class ServerThread extends Thread{
	Socket nowSocket = null;
	BufferedReader in =null;
	PrintWriter out = null;
	public ServerThread(Socket s) {
		this.nowSocket = s;  // 获取当前客户端
	}
	
//	public void run() {
//		try {
//			in = new BufferedReader(new InputStreamReader(nowSocket.getInputStream()));  // 输入流
//			while (true) {// 获取客户端信息并把信息发送给所有客户端
//				String str = in.readLine();
//				char c = str.charAt(str.length() - 1);
//				System.out.println("1这里得到的是："+str);
//				System.out.println("这里得到的map大小是："+MultiServer.mapServer.size());
//				int otherSocket = MultiServer.mapServer.get(nowSocket);
//				System.out.println("这里得到的localport是："+otherSocket);
//				if (c == 's') {
//					for (Socket socket : MultiServer.list) {// 发送给所有客户端
//						out = new PrintWriter(socket.getOutputStream());
//						if (socket == nowSocket) {  // 发送给当前客户端
//							out.println("(你)" + str.substring(0, str.length() - 1));
//						} else if (socket.getLocalPort() == otherSocket) {  // 发送给其它客户端
//							out.println(str.substring(0, str.length() - 1));
//						}
//						out.flush();
//					}
//
//
//					System.out.println(str);
//
//				} else {
//					System.out.println("到没有s这里");
//					for (Socket socket : MultiServer.list) {// 发送给所有客户端
//						out = new PrintWriter(socket.getOutputStream());
//						if (socket == nowSocket) {  // 发送给当前客户端
//							out.println("(你)" + str);
//						} else {  // 发送给其它客户端
//							out.println(str);
//						}
//						out.flush();
//					}
//					System.out.println(str);
//				}
//			}
//
//		} catch (Exception e) {
//			MultiServer.list.remove(nowSocket);  // 线程关闭，移除相应套接字
//		}
//	}


//	public void run(){
//		try {
//			in = new BufferedReader(new InputStreamReader(nowSocket.getInputStream()));  // 输入流
//			while (true) {// 获取客户端信息并把信息发送给所有客户端
//				String str = in.readLine();
//				for(Socket socket: MultiServer.list) {// 发送给所有客户端
//					out = new PrintWriter(socket.getOutputStream());
//					if(socket == nowSocket) {  // 发送给当前客户端
//						out.println("(你)" + str);
//					}
//					else {  // 发送给其它客户端
//						out.println(str);
//					}
//					out.flush();
//				}
//				System.out.println(str);
//			}
//		} catch (Exception e) {
//			MultiServer.list.remove(nowSocket);  // 线程关闭，移除相应套接字
//		}
//	}


		public void run(){
		try {
			in = new BufferedReader(new InputStreamReader(nowSocket.getInputStream()));  // 输入流
			while (true) {// 获取客户端信息并把信息发送给所有客户端
				String str = in.readLine();
				char c = str.charAt(str.length() - 1);
				System.out.println("run"+str);
				if(c=='s'){
					System.out.println("run1"+str);
					String str2=str.substring(str.length() - 6,str.length() - 1);
					System.out.println("run2"+str2);
					int inum = Integer.parseInt(str2);
					System.out.println(MultiServer.list);
					for(Socket socket: MultiServer.list) {// 发送给所有客户端
						out = new PrintWriter(socket.getOutputStream());
						System.out.println("\u8FD9\u91CC\u904D\u5386\uFF1A");
						System.out.println(socket.getLocalPort());
						if(socket == nowSocket) {  // 发送给当前客户端
							out.println("(u)" + str.substring(0,str.length() - 6));
						}
						else if(socket.getPort()==inum){  // 发送给其它客户端
							System.out.println("\u79C1\u804A\u53D1\u51FA\u6765");
							out.println(str.substring(0,str.length() - 6));
						}
						out.flush();
					}
				}
				else{
				for(Socket socket: MultiServer.list) {// 发送给所有客户端
					out = new PrintWriter(socket.getOutputStream());
					if(socket == nowSocket) {  // 发送给当前客户端
						out.println("(u)" + str);
					}
					else {  // 发送给其它客户端
						out.println(str);
					}
					out.flush();
				}
				System.out.println(str);
			}}

		} catch (Exception e) {
			MultiServer.list.remove(nowSocket);  // 线程关闭，移除相应套接字
		}
	}
}
