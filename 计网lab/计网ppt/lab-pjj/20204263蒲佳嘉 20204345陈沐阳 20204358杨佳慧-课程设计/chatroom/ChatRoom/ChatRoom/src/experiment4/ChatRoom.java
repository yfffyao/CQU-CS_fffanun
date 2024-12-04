package experiment4;

import javax.swing.*;
import javax.swing.border.EmptyBorder;
import javax.swing.event.ListSelectionEvent;
import javax.swing.event.ListSelectionListener;
import javax.swing.filechooser.FileNameExtensionFilter;

import java.io.File;

import java.awt.event.ActionListener;
import java.awt.event.ActionEvent;
import java.io.IOException;
import java.io.PrintWriter;
import java.net.InetAddress;
import java.net.Socket;
import java.util.*;

//用户聊天框
@SuppressWarnings("serial")
public class ChatRoom extends JFrame {
	static ClientListener.ChatViewListen listener;
//	static ClientListener.chatAloneListen listener1;
	static PrintWriter out = null;
	static String userName;
	JPanel view;
	static Socket mySocket;
	static JFrame chatViewJFrame;
	DefaultListModel listModel;
	JTextArea textArea;
	JTextField text;
	JButton button;
	JButton refreshButton;
	JList jList;
	String chatWith;

	JScrollPane scrollPane;
	User user=new User();
	static int type=0;//默认0是群聊，1是私聊
	static int otherport=0;//与你私聊的人的port号
	/**
	 * Create the frame.
	 */
	public ChatRoom(String name) {
		userName = name;
		init();

	}
	public ChatRoom(String name,int type,int otherport) {
		userName = name;
		this.type=type;
		this.otherport=otherport;

		init();
	}
	
	void init() {
		setTitle("\u804A\u5929\u5BA4");
		setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		setBounds(500, 200, 500,390);
		view = new JPanel();
		view.setBorder(new EmptyBorder(0, 0, 0, 0));
		setContentPane(view);
		
		JLabel Label = new JLabel("\u7528\u6237\uFF1A"+userName);
		Label.setBounds(186, 0, 94, 32);
		
		text = new JTextField();
		text.setBounds(6, 310, 328, 27);
		text.setColumns(10);
		
		button = new JButton("\u53D1\u9001");
		button.setBounds(344, 310, 65, 27);

		refreshButton=new JButton("\u5237\u65B0");
		refreshButton.setBounds(412,15,60,25);
		view.add(refreshButton);
		refreshButton.addActionListener(new ActionListener() {
			@Override
			public void actionPerformed(ActionEvent e) {
				refreshActionPerformed(e);
			}
		});
//		String[] set = {"aa","bb","cc","dd","ee","ff","gg"};
		listModel=new DefaultListModel();
		Vector<String> set=user.list();

		for (String str : set ) {
			listModel.addElement(str);
		}

		jList=new JList(listModel);
		jList.setBounds(400,50,100,100);
		jList.setSelectionMode(ListSelectionModel.SINGLE_SELECTION);//设置单选
		JScrollPane jsp=new JScrollPane(jList);
		jsp.setBounds(400, 50, 80, 100);
		view.add(jsp);
		//点击后发生响应事件
		jList.addListSelectionListener(new ListSelectionListener() {
			@Override
			public void valueChanged(ListSelectionEvent e) {
				do_list_valueChanged(e);
			}
		});

		//打字区域
		scrollPane = new JScrollPane(textArea);
		scrollPane.setLocation(6, 42);
		scrollPane.setHorizontalScrollBarPolicy(JScrollPane.HORIZONTAL_SCROLLBAR_AS_NEEDED);
		scrollPane.setSize(370, 258);  //要用setSize设定固定大小
		scrollPane.setVerticalScrollBarPolicy(JScrollPane.VERTICAL_SCROLLBAR_ALWAYS);
		view.setLayout(null);
		view.add(text);
		view.add(button);
		view.add(scrollPane);
		
		textArea = new JTextArea("*******************\u6B22\u8FDB\u6765\u5230\u804A\u5929\u5BA4********************\n");
		scrollPane.setViewportView(textArea);
		view.add(Label);

		//添加监听
		listener = new ClientListener().new ChatViewListen();
		listener.setJTextField(text);
		listener.setJTextArea(textArea);
		
		JButton fileButton = new JButton("\u6587\u4EF6");
		JFrame jf = this;
		fileButton.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				FileOpen(jf);
			}
		});


		fileButton.setBounds(411, 310, 65, 27);
		view.add(fileButton);
//		view.add(fileButton2);
		listener.setChatViewJf(this);
		text.addActionListener(listener);
		button.addActionListener(listener);
		
		this.setVisible(true);
	}
	
	
	// 创建文件选择器
	void FileOpen(JFrame jf) {
		
		JFileChooser fileChooser = new JFileChooser();
		fileChooser.setCurrentDirectory(new File("D:/chatresource/"));// 设置默认显示的文件夹
        fileChooser.setFileFilter(new FileNameExtensionFilter("(txt)", "txt"));
		fileChooser.setFileFilter(new FileNameExtensionFilter("(jpg)", "jpg"));
 	    fileChooser.setFileFilter(new FileNameExtensionFilter("(png)", "png"));
 	    fileChooser.setFileFilter(new FileNameExtensionFilter("(pdf)", "pdf"));
 	    fileChooser.setFileFilter(new FileNameExtensionFilter("(xlsx)", "xlsx"));
 	    fileChooser.setFileFilter(new FileNameExtensionFilter("(docx)", "docx"));
		int result = fileChooser.showOpenDialog(jf);  // 对话框将会尽量显示在靠近 parent 的中心
		if(result == JFileChooser.APPROVE_OPTION) {//如果选择了文件
			File file = fileChooser.getSelectedFile();
			String path = file.getAbsolutePath();
			ClientFile.outFileToServer(path);
		}
	}
	protected void do_list_valueChanged(ListSelectionEvent e) {
		JOptionPane.showMessageDialog(this, "\u6211\u8981\u4E0E" +jList.getSelectedValue()+"\u79C1\u804A", "\u9009\u62E9\u79C1\u804A\u5BF9\u8C61", JOptionPane.INFORMATION_MESSAGE);

		String chatwithName=jList.getSelectedValue().toString();
		try {
			User user=new User();
			InetAddress addr = InetAddress.getByName(null);  // 获取主机地址
			MultiServer.mapServer=new HashMap<Socket, Integer>();
			System.out.println("\u79C1\u804A\u65F6\u804A\u5929\u5BF9\uFF1A"+chatwithName);
//			Socket ChatWithSocket=user.getSocketbyName(chatwithName);//得到对方的socket
			int localport=user.getLocalPortbyName(chatwithName);
			System.out.println("\u79C1\u804A\u65F6localport:"+localport);
			ChatRoom chatview=new ChatRoom(userName+"&"+jList.getSelectedValue()+"\u79C1\u804A",1,localport);
//			chatview.setBounds(186, 0, 150, 32);
			mySocket = new Socket(addr,53660);
			MultiServer.mapServer.put(mySocket,localport);
			out = new PrintWriter(mySocket.getOutputStream());  // 输出流
			out.println("\u5F00\u542F\u79C1\u804A");  // 发送用户名给服务器
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
	private void refreshActionPerformed(ActionEvent evt) {
		Vector<String> set=user.list();
		listModel.clear();
		for (String str : set ) {
			listModel.addElement(str);
		}

	}
}
