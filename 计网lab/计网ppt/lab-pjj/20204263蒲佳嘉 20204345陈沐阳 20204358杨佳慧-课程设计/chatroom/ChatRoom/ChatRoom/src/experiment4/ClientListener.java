package experiment4;

import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.InetAddress;
import java.net.Socket;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.Map;

import javax.swing.*;
import javax.swing.event.ListSelectionEvent;
import javax.swing.event.ListSelectionListener;

public class ClientListener extends Thread{
	static Socket mySocket;
	static JTextField textInput;
	static JTextArea textShow;
	static JFrame chatViewJFrame;
	static JList jList;
	static BufferedReader in = null;
	static PrintWriter out = null;
	static String userName;	//用户名


	User user=new User();
	
	// 用于接收从服务端发送来的消息
	public void run() {
		try {
			in = new BufferedReader(new InputStreamReader(mySocket.getInputStream()));  // 输入流
			while (true) {
				String str = in.readLine();  // 获取服务端发送的信息

				textShow.append(str + '\n');  // 添加进聊天客户端的文本区域
				textShow.setCaretPosition(textShow.getDocument().getLength());
			}
		} catch (Exception e) {}
	}
	//私聊监听
//	static class chatAloneListen implements ListSelectionListener {
		String name;
		String userName1;
		JPanel contentPane;
		JFrame loginJFrame;  // 登录窗口本身
		ChatRoom chatview;
//		public chatAloneListen(String chatWith,String userName1){
//			this.name=chatWith;
//			this.userName1=userName1;
//		}
//		public void setJPane(JPanel pane) {
//			this.contentPane = pane;
//		}
//		@Override
//		public void valueChanged(ListSelectionEvent e) {
//			ChatRoom chatview = new ChatRoom(name);
//			try {
//				InetAddress addr = InetAddress.getByName(null);  // 获取主机地址
//				mySocket = new Socket(addr,5500);
//				loginJFrame.setVisible(false);  // 隐藏登录窗口
//				out = new PrintWriter(mySocket.getOutputStream());  // 输出流
//				out.println("用户[" + userName1 + "]进入聊天室！");  // 发送用户名给服务器
//				out.flush();  // 清空缓冲区out中的数据
//			} catch (IOException a) {
//				a.printStackTrace();
//			}
//			ClientListener readAndPrint = new ClientListener();
//			readAndPrint.start();
//			// 新建文件读写线程并启动
//			ClientFile fileThread = new ClientFile(userName1, chatViewJFrame, out);
//			fileThread.start();
//		}
//	}
	//登录界面监听
	class LoginListen implements ActionListener{
		JTextField textField;
		JPanel contentPane;
		JFrame loginJFrame;  // 登录窗口本身
		ChatRoom chatview;


		public void setJTextField(JTextField textField) {
			this.textField = textField;
		}
		public void setJFrame(JFrame frame) {
			this.loginJFrame = frame;
		}
		public void setJPane(JPanel pane) {
			this.contentPane = pane;
		}

		//点击登录之后到这里来了
		@Override
		public void actionPerformed(ActionEvent e) {
			// TODO Auto-generated method stub
			userName = textField.getText();
//			user.setUsername(userName);
			chatview = new ChatRoom(userName);
			try {
				InetAddress addr = InetAddress.getByName(null);  // 获取主机地址
				mySocket = new Socket(addr,53660);

				System.out.println("mysocket\uFF1A"+mySocket);
				System.out.println("userName\uFF1A"+userName);
				user.setSocket(userName,mySocket);
				loginJFrame.setVisible(false);  // 隐藏登录窗口
				out = new PrintWriter(mySocket.getOutputStream());  // 输出流
				out.println("\u7528\u6237[" + userName + "]\u8FDB\u5165\u804A\u5929\u5BA4\uFF01");  // 发送用户名给服务器
				out.flush();  // 清空缓冲区out中的数据
			} catch (IOException a) {
				a.printStackTrace();
			}
			ClientListener readAndPrint = new ClientListener();
			readAndPrint.start();
			// 新建文件读写线程并启动
			ClientFile fileThread = new ClientFile(userName, chatViewJFrame, out);
			fileThread.start();
		}
		
	}
	

	//聊天界面监听
	class ChatViewListen implements ActionListener{
		public void setJTextField(JTextField text) {
			textInput = text; 
		}
		public void setJTextArea(JTextArea textArea) {
			textShow = textArea;
		}
		public void setChatViewJf(JFrame jFrame) {
			chatViewJFrame = jFrame;
			chatViewJFrame.addWindowListener(new WindowAdapter() {// 设置关闭聊天界面的监听
				public void windowClosing(WindowEvent e) {
					out.println("\u7528\u6237[" + userName + "]\u79BB\u5F00\u804A\u5929\u5BA4\uFF01");
					user.deleteUsername(userName);

					out.flush();
					System.exit(0);
				}
			});
		}

		//监听执行函数
		public void actionPerformed(ActionEvent event) {
			try {
				int type=ChatRoom.type;
				int port=ChatRoom.otherport;
				String str = textInput.getText();
				System.out.println("I'm listening here for "+type);
				// 文本框内容为空
				if("".equals(str)) {
					textInput.grabFocus();
					JOptionPane.showMessageDialog(chatViewJFrame, "\u8F93\u5165\u4E3A\u7A7A\u8BF7\u91CD\u65B0\u8F93\u5165\uFF01", "\u63D0\u793A", JOptionPane.WARNING_MESSAGE);// 弹出消息对话框（警告消息）
					return;
				}
				LocalDateTime t = LocalDateTime.now();	//获取本地时间并格式化
				DateTimeFormatter formatter = DateTimeFormatter.ofPattern("YYYY/MM/dd HH:mm:ss");
				String time = formatter.format(t);
				String s;
				if(type==1){
					System.out.println("type is "+type);
					s = userName + ": " + str + "   " + time+port+"s";
					System.out.println("\u53D1\u9001\uFF1A"+s);
				}
				else{
				s = userName + ": " + str + "   " + time;}
				// System.out.println("要发给服务器了");
				out.println(s);  // 输出给服务端
				out.flush();  // 清空缓冲区out中的数据
				textInput.setText("");  // 清空文本框
				textInput.grabFocus();
			} catch (Exception e) {}
		}
	}
}
