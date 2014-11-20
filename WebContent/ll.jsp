<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,java.util.*,java.text.*,javax.naming.*,javax.sql.*" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Insert title here</title>
</head>
<body>
<%
		String rMsg="";
		String u=request.getParameter("userid");
		String p=request.getParameter("passwd");
		String sql="select usertype from smppuser where userid=? and passwd=md5(?)";
		String sqlaction="insert into smppuseraction values (?,?,'login')";
		String logindate = new SimpleDateFormat("yyyyMMddHHmmss").format(new java.util.Date());
		PreparedStatement ps=null;
		PreparedStatement ps1=null;
		ResultSet rs = null;
		Context ctx = new InitialContext();
		Context env=(Context)ctx.lookup("java:comp/env");
		DataSource ds =(DataSource)env.lookup("jdbc/SMPPDB");        
		Connection conn = ds.getConnection();
		if (conn==null){
			rMsg="do Login Error in get Connection:";
			return;
		}
		int r=0;
		String mtype="";
		try {
			ps = conn.prepareStatement(sql);
			ps.setString(1,u);
			ps.setString(2,p);
			rs = ps.executeQuery();
			if (rs.next()){
				r=1;
				mtype=rs.getString("usertype");
				if (mtype==null||mtype.trim().equals("")){
					r=-1;
				}else{
					session.setAttribute("mytype", mtype);
					session.setAttribute("memberid",u);
					ps1 = conn.prepareStatement(sqlaction);
					ps1.setString(1,u);
					ps1.setString(2,logindate);
					ps1.executeUpdate();
				}
			}else{
				out.print("使用者名稱或密碼錯誤");
			}
		} catch (SQLException sqle) {
			rMsg="login Exception:"+sqle.getMessage();
			System.out.println(rMsg);
			r=-1;
		}finally{
			try{
				rs.close();
				ps.close();
				ps1.close();
				conn.close();
			}catch(Exception e){
			}
			if (r==-1){
				response.sendRedirect("signon.jsp");
			}else
			if (mtype.equals("99")){
				response.sendRedirect("adminbed.jsp");
			}else
			if (mtype.equals("1")){
				response.sendRedirect("reportbed.jsp");
			}else
			if (mtype.equals("9")){
				response.sendRedirect("adminbed.jsp");
			}
		}
%>

</body>
</html>