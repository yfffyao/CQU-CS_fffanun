package experiment4;

import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.IOException;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.ArrayList;
import java.util.List;

//服务器端文件传输
public class ServerFileThread extends Thread{
	ServerSocket server = null;
	Socket socket = null;
	static List<Socket> list = new ArrayList<Socket>();  // 存储客户端

	public void run() {
		try {
			server = new ServerSocket(8090);
			while(true) {
				socket = server.accept();
				list.add(socket);
				// 开启文件传输线程
				FileReadAndWrite fileReadAndWrite = new FileReadAndWrite(socket);
				fileReadAndWrite.start();
			}
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
}

class FileReadAndWrite extends Thread {
	private Socket nowSocket = null;
	private DataInputStream input = null;
	private DataOutputStream output = null;

	public FileReadAndWrite(Socket socket) {
		this.nowSocket = socket;
	}
	public void run() {
		try {
			input = new DataInputStream(nowSocket.getInputStream());
			while (true) {
				String textName = input.readUTF();
				long textLength = input.readLong();
				for(Socket socket: ServerFileThread.list) {//发送文件名字和文件长度给所有客户端
					output = new DataOutputStream(socket.getOutputStream());
					if(socket != nowSocket) {
						output.writeUTF(textName);
						output.flush();
						output.writeLong(textLength);
						output.flush();
					}
				}
				// 发送文件内容
				int length = -1;
				long curLength = 0;
				byte[] buff = new byte[1024];
				while ((length = input.read(buff)) > 0) {
					curLength += length;
					for(Socket socket: ServerFileThread.list) {
						output = new DataOutputStream(socket.getOutputStream());
						if(socket != nowSocket) {
							output.write(buff, 0, length);
							output.flush();
						}
					}
					if(curLength == textLength) {
						break;
					}
				}
			}
		} catch (Exception e) {
			ServerFileThread.list.remove(nowSocket);  // 线程关闭
		}
	}
}
