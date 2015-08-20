<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,java.util.*,java.text.*,javax.naming.*,javax.sql.*" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>新增</title>
    <script type="text/javascript" src="JSCal2-1.7/src/js/jscal2.js"></script>
    <script type="text/javascript" src="JSCal2-1.7/src/js/lang/b5.js"></script>
    <link type="text/css" rel="stylesheet" href="JSCal2-1.7/src/css/jscal2.css" />
<style type="text/css">

.basictab{
padding: 3px 0;
margin-left: 0;
font: bold 12px Verdana;
border-bottom: 1px solid gray;
list-style-type: none;
text-align: left; /*set to left, center, or right to align the menu as desired*/
}

.basictab li{
display: inline;
margin: 0;
}

.basictab li a{
text-decoration: none;
padding: 3px 7px;
margin-right: 3px;
border: 1px solid gray;
border-bottom: none;
background-color: #f6ffd5;
color: #2d2b2b;
}

.basictab li a:visited{
color: #2d2b2b;
}

.basictab li a:hover{
background-color: #DBFF6C;
color: black;
}

.basictab li a:active{
color: black;
}

.basictab li.selected a{ /*selected tab effect*/
position: relative;
top: 1px;
padding-top: 4px;
background-color: #DBFF6C;
color: black;
}

</style>
<script>
function passcheck(){
	if (document.getElementById('pwd').value==document.getElementById('pwd1').value){
		return true;
	}else{
		alert('密碼錯誤');
		return false;
	}
}
</script>
</head>

<body>
<ul class="basictab">
<li class="selected"><a href="adminbed.jsp">客戶管理</a></li>
<li><a href="reportbed.jsp">報表查詢</a></li>
<li ><a href="http://www.dynamicdrive.com/style/">CSS</a></li>
<li><a href="http://www.dynamicdrive.com/forums/">Forums</a></li>
<li><a href="http://tools.dynamicdrive.com/imageoptimizer/">Gif Optimizer</a></li>
<li><a href="http://tools.dynamicdrive.com/button/">Button Maker</a></li>
</ul>
<%
	if (session.getAttribute("mytype")==null){
		response.sendRedirect("index.html");
		return;
	}
	if (!(((String)session.getAttribute("mytype")).equals("99")||((String)session.getAttribute("mytype")).equals("9"))){
		response.sendRedirect("index.html");
		return;
	}
	String rMsg="";
	String u="";
	String n="";	
	String e="";	
	String c="";	
	String o="";	
	String f="";	
	String a="";	
	int query=0;
	if (request.getParameter("did")!=null){
		PreparedStatement ps=null;
		PreparedStatement ps1=null;
		PreparedStatement psaction=null;
		Context ctx = new InitialContext();
		Context env=(Context)ctx.lookup("java:comp/env");
		DataSource ds =(DataSource)env.lookup("jdbc/SMPPDB");        
		Connection conn = ds.getConnection();
		String sql="delete * from smppuserinfo where userid=?";
		String sql1="delete * from smppuser where userid=?";
		try {
			String logindate = new SimpleDateFormat("yyyyMMddHHmmss").format(new java.util.Date());
			ps = conn.prepareStatement(sql);
			ps.setString(1,request.getParameter("did"));
			ps.executeUpdate();
			ps1 = conn.prepareStatement(sql1);
			ps1.setString(1,request.getParameter("did"));
			ps1.executeUpdate();
			out.println("<script>alert('使用者刪除成功!!');document.window.href ='adminbed.jsp'; </script>");
			String sqlaction="insert into smppuseraction values (?,?,'刪除使用者'"+request.getParameter("did")+")";
			psaction = conn.prepareStatement(sqlaction);
			psaction.setString(1,u);
			psaction.setString(2,logindate);
			psaction.executeUpdate();
		} catch (SQLException sqle) {
			rMsg="Query Exception:"+sqle.getMessage();
			out.println(rMsg);
		}finally{
			try{
				ps.close();
				ps1.close();
				conn.close();
			}catch(Exception e1){
			}
		}
	}
%>
</body>
</html>
