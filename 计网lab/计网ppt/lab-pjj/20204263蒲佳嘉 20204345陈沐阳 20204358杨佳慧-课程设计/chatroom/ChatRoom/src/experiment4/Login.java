package experiment4;

import javax.swing.JFrame;
import javax.swing.JPanel;
import javax.swing.border.EmptyBorder;
import javax.swing.JTextField;
import javax.swing.JLabel;
import javax.swing.JButton;

@SuppressWarnings("serial")
public class Login extends JFrame {
	JPanel contentPane;
	JTextField textField = null;
	ClientListener.LoginListen listener;

	public static void main(String[] args) {
		new Login();
	}
	
	public Login() {
		init();
	}

	/**
	 * Create the frame.
	 */
	public void init() {
		User user;
		setTitle("\u767B\u5F55");
		setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		setBounds(100, 100, 300, 150);
		contentPane = new JPanel();
		contentPane.setToolTipText("");
		contentPane.setBorder(new EmptyBorder(5, 5, 5, 5));
		setContentPane(contentPane);
		contentPane.setLayout(null);
		
		textField = new JTextField();
		
		textField.setBounds(76, 30, 166, 21);
		contentPane.add(textField);
		textField.setColumns(10);
		
		JLabel lblNewLabel = new JLabel("\u7528\u6237\u540D");
		lblNewLabel.setBounds(23, 33, 43, 15);
		contentPane.add(lblNewLabel);
		
		JButton btnNewButton = new JButton("\u767B\u5F55");//µÇÂ¼°´Å¥
		btnNewButton.setBounds(102, 65, 97, 23);
		contentPane.add(btnNewButton);
		
		//ÉèÖÃ¼à¿Ø
		listener = new ClientListener().new LoginListen();
		textField.addActionListener(listener);
		listener.setJTextField(textField);
		listener.setJPane(contentPane);
		listener.setJFrame(this);
		btnNewButton.addActionListener(listener);
		
		this.setVisible(true);
	}
}
