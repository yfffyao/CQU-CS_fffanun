package experiment4;

import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.PrintWriter;
import java.net.InetAddress;
import java.net.Socket;

import javax.swing.JFrame;
import javax.swing.JOptionPane;

public class ClientFile extends Thread{
	private Socket socket = null;
	private JFrame chatViewJFrame = null;
	static String userName = null;
	static PrintWriter out = null;
	static DataInputStream fileIn = null;
	static DataOutputStream fileOut = null;
	static DataInputStream fileReader = null;
	static DataOutputStream fileWriter = null;
	
	public ClientFile(String userName, JFrame chatViewJFrame, PrintWriter out) {
		ClientFile.userName = userName;
		this.chatViewJFrame = chatViewJFrame;
		ClientFile.out = out;
	}
	
	// 客户端接收文件
	public void run() {
		try {
			InetAddress addr = InetAddress.getByName(null);
			socket = new Socket(addr, 8090);  
			fileIn = new DataInputStream(socket.getInputStream()); 
			fileOut = new DataOutputStream(socket.getOutputStream());
			//接收文件
			while(true) {
				String textName = fileIn.readUTF();
				long totleLength = fileIn.readLong();
				int result = JOptionPane.showConfirmDialog(chatViewJFrame, "\u662F\u5426\u63A5\u53D7\uFF1F", "\u63D0\u793A",
														   JOptionPane.YES_NO_OPTION);
				int length = -1;
				byte[] buff = new byte[1024];
				long curLength = 0;
				//提示框选择结果，0为确定接收，1为拒绝接收
				if(result == 0){
					out.println("【" + userName + "\u9009\u62E9\u63A5\u6536\u6587\u4EF6\uFF01】");
					out.flush();
					File userFile = new File("D:/test/" + userName);
					if(!userFile.exists()) {  //如果文件夹不存在则新建当前用户的文件夹
						userFile.mkdir();
					}
					File file = new File("D:/test/" + userName + "/" + textName);
					fileWriter = new DataOutputStream(new FileOutputStream(file));
					while((length = fileIn.read(buff)) > 0) {
						fileWriter.write(buff, 0, length);
						fileWriter.flush();
						curLength += length;
						if(curLength == totleLength) {  //结束
							break;
						}
					}
					out.println("【" + userName + "\u6587\u4EF6\u63A5\u6536\u6210\u529F\uFF01】");
					out.flush();
				}
				else {  // 不接受文件
					out.println("【" + userName + "\u62D2\u7ED9\u63A5\u6536\u6587\u4EF6\uFF01】");
					while((length = fileIn.read(buff)) > 0) {
						curLength += length;
						if(curLength == totleLength) {  //结束
							break;
						}
					}
				}
				fileWriter.close();
			}
		} catch (Exception e) {}
	}
	
	// 客户端发送文件
	static void outFileToServer(String path) {
		try {
			File file = new File(path);
			fileReader = new DataInputStream(new FileInputStream(file));
			fileOut.writeUTF(file.getName());  // 发送文件名字
			fileOut.flush();
			fileOut.writeLong(file.length());  // 发送文件长度
			fileOut.flush();
			int length = -1;
			byte[] buff = new byte[1024];
			while ((length = fileReader.read(buff)) > 0) {  // 发送内容
				
				fileOut.write(buff, 0, length);
				fileOut.flush();
			}
			out.println("【" + userName + "\u8BF7\u6C42\u53D1\u9001\u6587\u4EF6\uFF01】");
			out.flush();
		} catch (Exception e) {}
	}
}