<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,java.util.*,java.text.*,javax.naming.*,javax.sql.*" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>修改</title>
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
<li><a href="adminbed.jsp">客戶管理</a></li>
<li class="selected"><a href="adminbed.jsp">修改客戶資料</a></li>
<li><a href="reportbed.jsp">報表查詢</a></li>
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
	String p="";
	int query=0;
	if (request.getParameter("u")!=null){
		PreparedStatement ps=null;
		ResultSet rs = null;
		Context ctx = new InitialContext();
		Context env=(Context)ctx.lookup("java:comp/env");
		DataSource ds =(DataSource)env.lookup("jdbc/SMPPDB");        
		Connection conn = ds.getConnection();
		String sql="select * from smppuserinfo where userid=?";
		try {
			ps = conn.prepareStatement(sql);
			ps.setString(1,request.getParameter("u"));
			rs = ps.executeQuery();
			if (rs.next()){
				query=1;
				u=rs.getString("userid");
				n=rs.getString("uname");
				e=rs.getString("rid");
				c=rs.getString("contact");
				o=rs.getString("phone");
				f=rs.getString("fax");
				a=rs.getString("addr");
			}else{
				out.print("查無資料!!");
			}
		} catch (SQLException sqle) {
			rMsg="Query Exception:"+sqle.getMessage();
			out.println(rMsg);
		}finally{
			try{
				rs.close();
				ps.close();
				conn.close();
			}catch(Exception e1){
			}
		}
	}else{
		u=request.getParameter("userid");
		p=request.getParameter("pwd");
		n=request.getParameter("uname");
		if (n!=null){
			n=new String(request.getParameter("uname").getBytes("iso8859-1"),"utf-8");
		}
		e=request.getParameter("rid");
		c=request.getParameter("cname");
		if (c!=null){
			c=new String(request.getParameter("cname").getBytes("iso8859-1"),"utf-8");
		}
		o=request.getParameter("phone");
		f=request.getParameter("fax");
		a=request.getParameter("addr");
		if (a!=null){
			a=new String(request.getParameter("addr").getBytes("iso8859-1"),"utf-8");
		}
		String logindate = new SimpleDateFormat("yyyyMMddHHmmss").format(new java.util.Date());
		
		int error=0;
		if (u.trim().equals("")){
			error=1;
		}
		if (n.trim().equals("")){
			error=3;
		}
		if (error==0){
			PreparedStatement ps=null;
			PreparedStatement ps1=null;
			PreparedStatement psaction=null;
			ResultSet rs = null;
			Context ctx = new InitialContext();
			Context env=(Context)ctx.lookup("java:comp/env");
			DataSource ds =(DataSource)env.lookup("jdbc/SMPPDB");        
			Connection conn = ds.getConnection();

			String sql1="update smppuserinfo set uname=?,rid=?,contact=?,phone=?,fax=?,addr=? where userid=?";
			String sql="update smppuser set passwd=md5(?) where userid=?";
			try {
				if (!p.trim().equals("")){
					ps = conn.prepareStatement(sql);
					ps.setString(2,u);
					ps.setString(1,p);
					ps.executeUpdate();
				}
				ps1 = conn.prepareStatement(sql1);
				ps1.setString(1,n);
				ps1.setString(2,e);
				ps1.setString(3,c);
				ps1.setString(4,o);
				ps1.setString(5,f);
				ps1.setString(6,a);
				ps1.setString(7,u);
				ps1.executeUpdate();
				query=1;
				out.println("<font color='red'>使用者修改成功!!</font>");
				String sqlaction="insert into smppuseraction values (?,?,'修改使用者'"+u+")";
				psaction = conn.prepareStatement(sqlaction);
				psaction.setString(1,u);
				psaction.setString(2,logindate);
				psaction.executeUpdate();
			} catch (SQLException sqle) {
				rMsg="Insert Exception:"+sqle.getMessage();
				if (rMsg.indexOf("duplicate")>0){
					out.println("<font color='red'>使用者已存在!!</font>");
				}else{
					out.println(rMsg);
				}
			}finally{
				try{
					rs.close();
					ps.close();
					ps1.close();
					conn.close();
				}catch(Exception e2){
				}
			}
		}
	}
%>
<table width="100%" border="0" align="center">
  <tr>
    <td width="10%">&nbsp;</td>
    <td width="80%" align="center">修改客戶</td>
    <td width="10%">&nbsp;</td>
  </tr>
  <tr>
    <td width="10%">&nbsp;</td>
    <td width="80%"><form id="form1" name="form1" method="post" action="adminedtbed.jsp">
      <table width="100%" border="0">
        <tr>
          <td align="right"><label>*客戶代號</label></td>
          <td><%=query==1?u:""%><input name="userid" type="hidden" value="<%=query==1?u:""%>"/></td>
          <td>&nbsp;</td>
        </tr>
        <tr>
          <td align="right"><label>*密碼</label></td>
          <td><input name="pwd" type="password" maxlength="20" /><br/><input name="pwd1" type="password" maxlength="20" /></td>
          <td>&nbsp;</td>
        </tr>
        <tr>
          <td align="right"><label>*客戶名稱</label></td>
          <td><input name="uname" type="text" maxlength="40"  value="<%=query==1?n:""%>"/></td>
          <td>&nbsp;</td>
        </tr>
        <tr>
          <td align="right">統一編號</td>
          <td><input name="rid" type="text" maxlength="10"  value="<%=query==1?e:""%>"/></td>
          <td>&nbsp;</td>
        </tr>
        <tr>
          <td align="right">聯絡人姓名</td>
          <td><input name="cname" type="text" maxlength="20"  value="<%=query==1?c:""%>"/></td>
          <td>&nbsp;</td>
        </tr>
        <tr>
          <td align="right">電話</td>
          <td><input name="phone" type="text" maxlength="20"  value="<%=query==1?o:""%>"/></td>
          <td>&nbsp;</td>
        </tr>
        <tr>
          <td align="right">傳真</td>
          <td><input name="fax" type="text" maxlength="20"  value="<%=query==1?f:""%>"/></td>
          <td>&nbsp;</td>
        </tr>
        <tr>
          <td align="right">地址</td>
          <td><input name="addr" type="text" maxlength="40"  value="<%=query==1?a:""%>"/></td>
          <td>&nbsp;</td>
        </tr>
        <tr align="center">
          <td align="center">&nbsp;</td>
          <td align="center"><input type="submit" name="ins" id="ins" value="修改" onsubmit="return passcheck()" /></td>
          <td>&nbsp;</td>
        </tr>
      </table>
    </form></td>
    <td width="10%">&nbsp;</td>
  </tr>
  <tr >
    <td width="10%">&nbsp;</td>
    <td width="80%">&nbsp;</td>
    <td width="10%">&nbsp;</td>
  </tr>
</table>
</body>
</html>
