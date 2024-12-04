package experiment4;
import java.io.IOException;
import java.net.InetAddress;
import java.net.Socket;
import java.net.UnknownHostException;
import java.sql.*;
import java.net.URI;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.util.Collections;
import java.util.HashSet;
import java.util.Set;
import java.util.Vector;

public class User {
    private String username;

    private Socket socket;

//    public String getUsername() {
//        return username;
//    }
//连接数据库
    public Connection getConnection(){
        try{
            Class.forName("com.mysql.cj.jdbc.Driver");
            return DriverManager.getConnection("jdbc:mysql://10.230.25.20:3306/my_database","root","20214600");
        }catch(ClassNotFoundException e){
            e.printStackTrace();
        }catch(SQLException e){
            e.printStackTrace();
        }
        return null;
    }
    //断开连接
    public void closeConn(Connection conn){
        try {
            conn.close();
        } catch (SQLException e) {
            // TODO Auto-generated catch block
            System.out.println("\u6570\u636E\u5E93\u5173\u95ED\u5F02\u5E38");
            e.printStackTrace();
        }
    }
    public int deleteUsername(String name) {

        Connection  conn=getConnection();
        int i = 0;
        String sql = "delete from my_db where name='" + name + "'";
        PreparedStatement pstmt;
        try {
            pstmt = (PreparedStatement) conn.prepareStatement(sql);
            i = pstmt.executeUpdate();
            System.out.println("result: " + i);
            pstmt.close();
            conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return i;
    }

    public int setUsername(String username) {
        this.username = username;
            Connection  conn=getConnection();//创建数据库连接
            String sql = "insert into my_db (name) values(?)";//定义sql语句
            PreparedStatement pstmt;
            int i=0;
            try {
                pstmt = (PreparedStatement) conn.prepareStatement(sql);
                pstmt.setString(1,username);
                i = pstmt.executeUpdate();
                pstmt.close();
                conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
                try{
                    conn.rollback();
                }catch(SQLException el){
                    el.printStackTrace();
                }
            }finally{
                closeConn(conn);
            }
            return i;

    }
    public int getLocalPortbyName(String Name) throws IOException {
        Connection  conn=getConnection();
        String sql="select * from my_db where name='"+Name+"'";
        int SocketPort = 0;
        String Socketlocal;
        String Addr = null;
        InetAddress addr1 = null;
        int SocketLocal = 0;
        try{Statement statement = conn.createStatement();
            ResultSet resultSet = statement.executeQuery(sql);
            while (resultSet.next()){

                SocketPort=resultSet.getInt("port");
                SocketLocal=resultSet.getInt("localport");
                Addr=resultSet.getString("addr");
//                addr1=InetAddress.getByName(Addr);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        } finally{
            closeConn(conn);}
//        Socketlocal=String.valueOf(SocketLocal);
//        Socket socket = new Socket(addr1,SocketPort);
        return SocketLocal;
    }


//    public Socket getSocketbyName(String Name) throws IOException {
//        Connection  conn=getConnection();
//        String sql="select * from my_db where name=Name";
//        int SocketPort = 0;
//        String Socketlocal;
//        String Addr = null;
//        InetAddress addr1 = null;
//        int SocketLocal = 0;
//        try{Statement statement = conn.createStatement();
//        ResultSet resultSet = statement.executeQuery(sql);
//        while (resultSet.next()){
//
//            SocketPort=resultSet.getInt("port");
//            SocketLocal=resultSet.getInt("localport");
//            Addr=resultSet.getString("addr");
//            addr1=InetAddress.getByName(Addr);
//        }
//
//        } catch (SQLException e) {
//        e.printStackTrace();
//    } catch (UnknownHostException e) {
//            throw new RuntimeException(e);
//        } finally{
//            closeConn(conn);}
//        Socketlocal=String.valueOf(SocketLocal);
//        Socket socket = new Socket(addr1,SocketPort);
//        return socket;
//    }

    public int  setSocket(String name,Socket socket) {
        this.socket = socket;
        int localport=socket.getLocalPort();
        System.out.println(localport);
        int port=socket.getPort();
        System.out.println(port);
        String addr= String.valueOf(socket.getInetAddress());
        System.out.println(addr);
        Connection conn=getConnection();
        String sql = "insert into my_db (name,localport,port,addr) values(?,?,?,?)";//定义sql语句
        PreparedStatement ps;
        int i=0;
        try {ps=conn.prepareStatement(sql);
            ps.setString(1,name);
        ps.setInt(2,localport);
        ps.setInt(3,port);
        ps.setString(4,addr);
        i = ps.executeUpdate();}
        catch(SQLException e) {
            e.printStackTrace();
            try{
                conn.rollback();
            }catch(SQLException el){
                el.printStackTrace();
            }
        }finally{
            closeConn(conn);
        }
        return i;
    }

    public Vector<String> list() {
        Connection conn = getConnection();
        String sql = "select * from my_db";
        PreparedStatement pstmt;
        Vector<String> vector =new Vector<>();
        Set<String> set=new HashSet<>();
        try {
            pstmt = (PreparedStatement)conn.prepareStatement(sql);
            ResultSet rs = pstmt.executeQuery();
            int col = rs.getMetaData().getColumnCount();//列数
            while (rs.next()) {//一行一行输出
                set.add(rs.getString(1));
                vector.add(rs.getString(1));

            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return vector;
    }
}







