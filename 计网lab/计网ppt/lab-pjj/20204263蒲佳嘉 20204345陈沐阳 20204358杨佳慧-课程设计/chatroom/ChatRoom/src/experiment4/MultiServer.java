package experiment4;

import java.io.IOException;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


//服务器文本聊天
public class MultiServer {
	static ServerSocket server = null;
	static Socket socket = null;
	static List<Socket> list = new ArrayList<Socket>();  // 存储客户端
	static Map<Socket, Integer> mapServer=new HashMap<>();
	public static void main(String[] args) {
		try {
			System.out.println("等待连接");

			// 在服务器端对客户端开启文件传输的线程
			ServerFileThread serverFileThread = new ServerFileThread();
			serverFileThread.start();
			server = new ServerSocket(5500);
			// 等待连接并开启相应线程
			while (true) {
				socket = server.accept();  // 等待连接
				list.add(socket);  // 添加当前客户端到列表
				// 在服务器端对客户端开启相应的线程
				ServerThread s = new ServerThread(socket);
				s.start();
				System.out.println("连接成功");
			}
		} catch (IOException e1) {
			e1.printStackTrace();  // 出现异常则打印出异常的位置
		}
	}
}