<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,java.util.*,java.text.*,javax.naming.*,javax.sql.*" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>管理</title>
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
function doDelete(d){
	var answer = confirm("確定冊除 "+d);
	if (answer){
			document.getElementById("did").value=d;
			document.getElementById("form2").submit();
	}
}
</script>
</head>

<body>
<%
	if (session.getAttribute("mytype")==null){
		response.sendRedirect("index.html");
		return;
	}
	if (!(((String)session.getAttribute("mytype")).equals("99")||((String)session.getAttribute("mytype")).equals("9"))){
		response.sendRedirect("index.html");
		return;
	}
%>
<ul class="basictab">
<li class="selected"><a href="adminbed.jsp">客戶管理</a></li>
<li><a href="admininsbed.jsp">新增客戶</a></li>
<li><a href="reportbed.jsp">報表查詢</a></li>

</ul>
<table width="100%" border="0" align="center">
  <tr>
    <td width="10%">&nbsp;</td>
    <td width="80%" align="center">客戶管理</td>
    <td width="10%">&nbsp;</td>
  </tr>
  <tr>
    <td width="10%">&nbsp;</td>
    <td width="80%"><form id="form1" name="form1" method="post" action="">
      <table width="100%" border="0">
        <tr>
          <td align="right"><label>客戶代號</label></td>
          <td><input name="userid" type="text" maxlength="20" /></td>
          <td>&nbsp;</td>
        </tr>
        <tr>
          <td align="right"><label>客戶名稱</label></td>
          <td><input name="uname" type="text" maxlength="20" /></td>
          <td>&nbsp;</td>
        </tr>
        <tr>
          <td align="right">統一編號</td>
          <td><input name="rid" type="text" maxlength="20" /></td>
          <td>&nbsp;</td>
        </tr>
        <tr>
          <td align="right"><label>建立日期</label></td>
          <td><input type="text" id="dfrom" name="dfrom" size="10" readonly="readonly" />
            <input type="button" value="..." id="BTN" name="BTN" />
            <script type="text/javascript">
        new Calendar({
            inputField: "dfrom",
            dateFormat: "%Y/%m/%d",
            trigger: "BTN",
            bottomBar: true,
            weekNumbers: true,
            showTime: 24,
            onSelect: function() {this.hide();}
        });
            </script>
            <input type="text" id="dto" name="dto" size="10" readonly="readonly" />
            <input type="button" value="..." id="BTN1" name="BTN1" />
            <script type="text/javascript">
        new Calendar({
            inputField: "dto",
            dateFormat: "%Y/%m/%d",
            trigger: "BTN1",
            bottomBar: true,
            weekNumbers: true,
            showTime: 24,
            onSelect: function() {this.hide();}
        });
            </script></td>
          <td>&nbsp;</td>
        </tr>
        <tr align="center">
          <td align="center">&nbsp;</td>
          <td align="center"><input name="submit" type="submit" value="查詢" /></td>
          <td></td>
        </tr>
      </table>
    </form><form id="form2" name="form2" method="post" action=""><input type="hidden" id="did" /></form></td>
    <td width="10%">&nbsp;</td>
  </tr>
  <tr >
    <td width="10%">&nbsp;</td>
    <td width="80%">&nbsp;</td>
    <td width="10%">&nbsp;</td>
  </tr>
</table>
<%
String rMsg="";
String u=request.getParameter("userid");
String n=request.getParameter("uname");
String r=request.getParameter("rid");
String f=request.getParameter("dfrom");
String t=request.getParameter("dto");
if (u!=null||n!=null||r!=null||f!=null||t!=null){
	if ((f!=null&&t==null)||(t!=null&&f==null)){
		out.print("<font color='red'>日期必需輸入起及迄</font>");
		return;
	}
	String sql="select s.userid,uname,rid from smppuser s, smppuserinfo i where s.userid=i.userid  ";
	String cc="";
	if (u!=null){
		if (!u.equals(""))
		cc+="and s.userid=?  ";
	}
	if (n!=null){
		if (!n.equals(""))
		cc+="and i.uname=?  ";
	}
	if (r!=null){
		if (!r.equals(""))
		cc+="and i.rid=?  ";
	}
	if (f!=null&&t!=null){
		if (!f.equals("")&&!t.equals(""))
		cc+="and createtime >=? and createtime<=? ";
	}
	PreparedStatement ps=null;
	ResultSet rs = null;
	Context ctx = new InitialContext();
	Context env=(Context)ctx.lookup("java:comp/env");
	DataSource ds =(DataSource)env.lookup("jdbc/SMPPDB");        
	Connection conn = ds.getConnection();
	try {
		ps = conn.prepareStatement(sql+cc);
		int pcount=1;
		if (u!=null){
			if (!u.equals("")){
				ps.setString(pcount,u);
				pcount++;
			}
		}
		if (n!=null){
			if (!n.equals("")){
				ps.setString(pcount,n);
				pcount++;
			}
		}
		if (r!=null){
			if (!r.equals("")){
				ps.setString(pcount,r);
				pcount++;
			}
		}
		if (f!=null&&t!=null){
			if (!f.equals("")&&!t.equals("")){
				ps.setString(pcount,f);
				pcount++;
				ps.setString(pcount,t);
				pcount++;
			}
		}
		rs = ps.executeQuery();
%>
<table width="100%" border="0">
  <tr>
    <th scope="col">客戶代號</th>
    <th scope="col">客戶名稱</th>
    <th scope="col">統一編號</th>
    <th scope="col">功能</th>
  </tr>
<%
		while (rs.next()){
%>
  <tr>
    <td><%=rs.getString("userid")%></td>
    <td><%=rs.getString("uname")%></td>
    <td><%=rs.getString("rid")%></td>
    <td>
		<input type="button" name="button" id="button" value="修改" onclick="window.location.href ='adminedtbed.jsp?u=<%=rs.getString("userid")%>'"/>
    <input type="button" name="button2" id="button2" value="刪除" onclick="doDelete(<%=rs.getString("userid")%>)"/>
		</td>
  </tr>
<%
		}
	} catch (SQLException sqle) {
		rMsg="Query Exception:"+sqle.getMessage();
		out.println(rMsg);
	}finally{
		try{
			rs.close();
			ps.close();
			conn.close();
		}catch(Exception e){
		}
%>
</table>
<%
	}
}//check if there submit something
%>
</body>
</html>
